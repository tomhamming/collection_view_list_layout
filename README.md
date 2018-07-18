# UICollectionView list layout with missing cells

An example project with a UICollectionViewLayout subclass for a UITableView-style layout, illustrating some [problems](https://stackoverflow.com/questions/51389649/how-do-i-accurately-provide-elements-in-a-rect-for-uicollectionviewlayout-before).

If you run the project and scroll down in the list, some cells are missing. This is because:

 - The estimated row height for the layout is set larger than cells will actually end up.
 - The layout queries for items in a given rect, via `layoutAttributesForElementsInRect`.
 - For each of those items, a cell gets built and sized, and its preferred size (which is smaller than the estimated height) gets applied to it and therefore the y offsets of all cells below it via `shouldInvalidateLayoutForPreferredLayoutAttributes` and `invalidationContextForPreferredLayoutAttributes` (followed by a call to `prepareLayout`).
 - This pulls more cells into view within the rect that was originally asked about, but `layoutAttributesForElementsInRect` doesn't always get called again so the layout can answer based on its new cell positions.
