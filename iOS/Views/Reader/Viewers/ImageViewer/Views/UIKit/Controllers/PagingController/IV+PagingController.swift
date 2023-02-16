//
//  IV+PagingController.swift
//  Mangareader (iOS)
//
//  Made on on 2023-08-08.
//

import Combine
import UIKit

extension Hashable {
    func isIn(_ set: Set<Self>) -> Bool {
        set.contains(self)
    }
}

class IVPagingController: UICollectionViewController {
    var preRotationPath: IndexPath?
    var subscriptions = Set<AnyCancellable>()
    var lastIndexPath: IndexPath = .init(item: 0, section: 0)
    var currentChapterRange: (min: CGFloat, max: CGFloat) = (min: .zero, max: .zero)
    var didTriggerBackTick = false
    var lastKnownScrollPosition: CGFloat = 0.0
    var scrollPositionUpdateThreshold: CGFloat = 20.0
    var dataSource: UICollectionViewDiffableDataSource<String, PanelViewerItem>!
    var widePages: Set<String> = []
    var onPageReadTask: Task<Void, Never>?
    var model: IVViewModel!
    var isLoaded = false
    var loadingTask: Task<Void, Never>?

    var isVertical = false
    var isDoublePager = false

    var dataCache: IVDataCache {
        model.dataCache
    }

    var isInverted: Bool {
        model.readingMode.isInverted
    }

    var readingMode: ReadingMode {
        model.readingMode
    }

    var offset: CGFloat {
        isVertical ? collectionView.contentOffset.y : collectionView.contentOffset.x
    }
}

typealias IVCC = IVPagingController

private typealias Controller = IVPagingController

extension Controller {
    override func viewDidLoad() {
        super.viewDidLoad()

        // General
        collectionView.isPagingEnabled = true
        collectionView.isHidden = true
        collectionView.scrollsToTop = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never

        // Layout Specific
        let layout = isVertical ? VImageViewerLayout() : HImageViewerLayout()

        if let layout = layout as? HImageViewerLayout {
            layout.readingMode = readingMode
        }

        collectionView.setCollectionViewLayout(layout, animated: false)

        // Final setup calls
        setReadingOrder()
        addTapGestures()
        subscribeAll()
        configureDataSource()
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }

    override var canBecomeFirstResponder: Bool {
        true
    }

    func updateReaderState(with chapter: ThreadSafeChapter, indexPath: IndexPath, offset _: CGFloat?) async {
        let hasNext = await dataCache.getChapter(after: chapter) != nil
        let hasPrev = await dataCache.getChapter(before: chapter) != nil
        let pages = await dataCache.getCount(chapter.id)
        let item = dataSource.itemIdentifier(for: indexPath)
        guard case let .page(page) = item else {
            Logger.shared.warn("invalid reader state", "updateReaderState")
            return
        }

        let state: CurrentViewerState = .init(chapter: chapter,
                                              page: page.page.number,
                                              pageCount: pages,
                                              hasPreviousChapter: hasPrev,
                                              hasNextChapter: hasNext)

        model.setViewerState(state)
    }

    func startup() {
        loadingTask = Task { [weak self] in
            guard let self else { return }
            await self.initialLoad()
            self.loadingTask = nil
        }
    }

    func hardReset() {
        lastIndexPath = .init(item: 0, section: 0)
        currentChapterRange = (min: .zero, max: .zero)
        didTriggerBackTick = false
        scrollPositionUpdateThreshold = 20.0
        widePages = []

        let snapshot = NSDiffableDataSourceSnapshot<String, PanelViewerItem>()
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension Controller {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        preRotationPath = collectionView.pathAtCenterOfScreen
        collectionView.collectionViewLayout.invalidateLayout()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        setNeedsUpdateOfHomeIndicatorAutoHidden()
        // start
        startup()
    }
}

// MARK: Transform

extension Controller {
    func setReadingOrder() {
        guard !isVertical else { return }
        collectionView.transform = isInverted ? CGAffineTransform(scaleX: -1, y: 1) : .identity
    }
}

extension Controller: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

// MARK: Data Source

extension Controller {
    func configureDataSource() {
        let SingleImageCellRegistration = UICollectionView.CellRegistration<PagedViewerImageCell, PanelPage> { [weak self] cell, _, data in
            cell.set(page: data, delegate: self)
            cell.setImage()
        }

        let DoubleImageCellRegistration = UICollectionView.CellRegistration<DoublePagedViewerImageCell, PanelPage> { [weak self] cell, _, data in
            cell.set(page: data, delegate: self)
            cell.setImage()
        }

        let TransitionCellRegistration = UICollectionView.CellRegistration<TransitionCell, ReaderTransition> { cell, _, data in
            cell.configure(data)
        }

        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            collectionView, indexPath, item -> UICollectionViewCell in
            switch item {
            case let .page(page):
                if page.secondaryPage == nil {
                    return collectionView.dequeueConfiguredReusableCell(using: SingleImageCellRegistration, for: indexPath, item: page)
                } else {
                    return collectionView.dequeueConfiguredReusableCell(using: DoubleImageCellRegistration, for: indexPath, item: page)
                }

            case let .transition(transition):
                return collectionView.dequeueConfiguredReusableCell(using: TransitionCellRegistration, for: indexPath, item: transition)
            }
        }
    }
}

// MARK: - Did End Displaying / Task Cancellation

extension Controller {
    override func collectionView(_: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let data = dataSource.itemIdentifier(for: indexPath)
        if case let .transition(transition) = data, transition.to != nil {
            STTHelpers.triggerHaptic()
        }
        guard let cell = cell as? CancellableImageCell else { return }
        cell.cancelTasks()
    }
}

// MARK: - Will Display / Chapter Preloading

extension Controller {
    override func collectionView(_: UICollectionView, willDisplay _: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let data = dataSource.itemIdentifier(for: indexPath)

        guard let data else { return }

        guard case let .page(target) = data else { return }
        let page = target.secondaryPage ?? target.page
        let current = page.number
        let count = page.chapterPageCount
        let chapter = page.chapter

        // Chapter Completed
        if page.isLastPage {
            didCompleteChapter(chapter)
        }

        // Preloading
        let inPreloadRange = count - current < 5 || page.isLastPage

        guard inPreloadRange else { return }

        Task { [weak self] in
            await self?.preload(after: chapter)
        }
    }

    func preload(after chapter: ThreadSafeChapter) async {
        let next = await dataCache.getChapter(after: chapter)

        guard let next else { return }

        let currentState = model.loadState[next]

        guard currentState == nil else { return } // only trigger if the chapter has not been loaded

        await load(next)
    }
}
