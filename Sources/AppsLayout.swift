import UIKit

/// Collection view layout for the iOS home screen apps
class AppsLayout: UICollectionViewLayout {

    var numberOfRows: Int = 0
    var numberOfColumns: Int = 0

    /// The cell's size, calculated to fit exactly to the frame's of the collection view
    private var cellSize: CGSize {
        get {
            guard let collectionView = self.collectionView else { return CGSize.zero }
            let width = collectionView.bounds.width/CGFloat(numberOfColumns)
            let height = collectionView.bounds.height/CGFloat(numberOfRows)
            return CGSize(width: width, height: height)
        }
    }

    /// The maximum number of items in a page
    private var maxNumberOfCellsPerPage: Int {
        get {
            return numberOfRows * numberOfColumns
        }
    }

    private var cache = [UICollectionViewLayoutAttributes]()

    /// Width will be incremented as the cell is calculated
    private var contentWidth: CGFloat = 0

    private var contentHeight: CGFloat {
        get {
            return self.collectionView?.bounds.height ?? 0.0
        }
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        guard let collectionView = self.collectionView else { return }
        
        /// The x-offset that all items in the current page starts with.
        /// This will increment to the starting of the next page whenever an item exceeds the height of the collection view
        var pageOffsetX: CGFloat = 0

        /// Every time this reaches `numberOfColumn`, breaks to next line.
        var columnCount: Int = 0

        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0

        // Loop through all items, lay them out.
        for item in 0..<collectionView.numberOfItems(inSection: 0) {

            // Reaches the end of column, breaks to next line.
            // 1) Resets x position
            // 2) Increases y position
            // 3) Resets column count
            if columnCount > numberOfColumns - 1 {
                xOffset = 0
                yOffset += cellSize.height
                columnCount = 0
            }

            // When yOffset exceeds, increments page.
            // 1) Increases pageOffsetX to the x of the next page
            // 2) Resets x and y offset
            if yOffset >= contentHeight {

                pageOffsetX += collectionView.bounds.width

                xOffset = 0
                yOffset = 0
                columnCount = 0
            }

            let indexPath = IndexPath(item: item, section: 0)
            let frame = CGRect(x: pageOffsetX + xOffset, y: yOffset, width: cellSize.width, height: cellSize.height)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)

            contentWidth = max(contentWidth, pageOffsetX + collectionView.bounds.width)

            xOffset += cellSize.width
            columnCount += 1
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.cache.filter { (attributes) -> Bool in
            return attributes.frame.intersects(rect)
        }
    }








}



















