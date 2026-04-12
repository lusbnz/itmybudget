import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        if rows.isEmpty { return .zero }
        
        let width = rows.map { $0.width }.max() ?? 0
        let height = rows.map { $0.height }.reduce(0, +) + CGFloat(rows.count - 1) * spacing
        
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        
        var currentY = bounds.minY
        for row in rows {
            var currentX = bounds.minX
            for index in row.range {
                let view = subviews[index]
                let size = view.sizeThatFits(.unspecified)
                view.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
                currentX += size.width + spacing
            }
            currentY += row.height + spacing
        }
    }

    private struct Row {
        var range: Range<Int>
        var width: CGFloat
        var height: CGFloat
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        let maxWidth = proposal.width ?? .infinity
        
        var currentRowRange: Range<Int> = 0..<0
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        
        for index in 0..<subviews.count {
            let view = subviews[index]
            let size = view.sizeThatFits(.unspecified)
            
            if currentRowWidth + size.width > maxWidth && !currentRowRange.isEmpty {
                rows.append(Row(range: currentRowRange, width: currentRowWidth - spacing, height: currentRowHeight))
                currentRowRange = index..<index
                currentRowWidth = 0
                currentRowHeight = 0
            }
            
            currentRowRange = currentRowRange.lowerBound..<(index + 1)
            currentRowWidth += size.width + spacing
            currentRowHeight = max(currentRowHeight, size.height)
        }
        
        if !currentRowRange.isEmpty {
            rows.append(Row(range: currentRowRange, width: currentRowWidth - spacing, height: currentRowHeight))
        }
        
        return rows
    }
}
