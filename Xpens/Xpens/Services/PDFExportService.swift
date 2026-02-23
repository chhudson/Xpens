import UIKit

enum PDFExportService {

    // MARK: - Page Constants

    private static let pageWidth: CGFloat = 612
    private static let pageHeight: CGFloat = 792
    private static let pageRect = CGRect(
        x: 0, y: 0, width: pageWidth, height: pageHeight
    )
    private static let margin: CGFloat = 50
    private static let contentWidth = pageWidth - margin * 2

    // MARK: - Fonts

    private static let titleFont = UIFont.systemFont(ofSize: 20, weight: .bold)
    private static let subtitleFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    private static let headerFont = UIFont.systemFont(ofSize: 10, weight: .bold)
    private static let bodyFont = UIFont.systemFont(ofSize: 10, weight: .regular)
    private static let totalFont = UIFont.systemFont(ofSize: 11, weight: .bold)

    // MARK: - Column Layout

    private static let columns: [(title: String, x: CGFloat, width: CGFloat)] = [
        ("Date",     50,  80),
        ("Category", 130, 90),
        ("Merchant", 220, 110),
        ("Client",   330, 110),
        ("Amount",   440, 122)
    ]

    // MARK: - Public API

    /// Generates a PDF report and returns a temporary file URL.
    static func exportToFile(
        expenses: [Expense],
        startDate: Date,
        endDate: Date
    ) throws -> URL {
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = renderer.pdfData { context in
            var pageNumber = 1
            var cursorY = beginPage(
                context: context,
                pageNumber: &pageNumber,
                startDate: startDate,
                endDate: endDate
            )

            // -- Summary Section --
            cursorY = drawSummary(
                expenses: expenses,
                cursorY: cursorY,
                context: context
            )

            cursorY += 16
            cursorY = drawTableHeader(cursorY: cursorY)

            // -- Group by category --
            let grouped = Dictionary(grouping: expenses) { $0.category?.id }
            let sortedGroups = grouped.sorted { lhs, rhs in
                let lhsOrder = lhs.value.first?.category?.sortOrder ?? Int.max
                let rhsOrder = rhs.value.first?.category?.sortOrder ?? Int.max
                return lhsOrder < rhsOrder
            }

            for (_, items) in sortedGroups {
                let categoryName = items.first?.category?.name ?? "Uncategorized"
                let sorted = items.sorted { $0.date < $1.date }

                for expense in sorted {
                    if cursorY + 20 > pageHeight - 60 {
                        drawFooter(pageNumber: pageNumber)
                        pageNumber += 1
                        cursorY = beginNewPage(
                            context: context,
                            pageNumber: &pageNumber
                        )
                        cursorY = drawTableHeader(cursorY: cursorY)
                    }
                    cursorY = drawExpenseRow(
                        expense: expense, cursorY: cursorY
                    )
                }

                // Category subtotal
                let subtotal = items.reduce(Decimal.zero) { $0 + $1.amount }
                cursorY = drawSubtotal(
                    label: "\(categoryName) Subtotal",
                    amount: subtotal,
                    cursorY: cursorY
                )
            }

            // -- Grand Total --
            let grandTotal = expenses.reduce(Decimal.zero) { $0 + $1.amount }
            cursorY = drawGrandTotal(amount: grandTotal, cursorY: cursorY)

            drawFooter(pageNumber: pageNumber)
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "Xpens_Report_\(fileTimestamp()).pdf"
            )
        try data.write(to: url)
        return url
    }

    // MARK: - Page Management

    private static func beginPage(
        context: UIGraphicsPDFRendererContext,
        pageNumber: inout Int,
        startDate: Date,
        endDate: Date
    ) -> CGFloat {
        context.beginPage()
        var y = margin

        // Title
        let title: NSString = "Expense Report"
        title.draw(
            in: CGRect(x: margin, y: y, width: contentWidth, height: 28),
            withAttributes: [.font: titleFont]
        )
        y += 30

        // Date range
        let range = "\(startDate.displayString) -- \(endDate.displayString)"
        (range as NSString).draw(
            in: CGRect(x: margin, y: y, width: contentWidth, height: 16),
            withAttributes: [.font: subtitleFont, .foregroundColor: UIColor.darkGray]
        )
        y += 16

        // Generated date
        let generated = "Generated: \(Date().displayString)"
        (generated as NSString).draw(
            in: CGRect(x: margin, y: y, width: contentWidth, height: 16),
            withAttributes: [.font: subtitleFont, .foregroundColor: UIColor.darkGray]
        )
        y += 24

        // Separator line
        drawHorizontalLine(y: y)
        y += 8
        return y
    }

    private static func beginNewPage(
        context: UIGraphicsPDFRendererContext,
        pageNumber: inout Int
    ) -> CGFloat {
        context.beginPage()
        return margin
    }

    // MARK: - Summary

    private static func drawSummary(
        expenses: [Expense],
        cursorY: CGFloat,
        context: UIGraphicsPDFRendererContext
    ) -> CGFloat {
        var y = cursorY
        let total = expenses.reduce(Decimal.zero) { $0 + $1.amount }

        let summaryLines: [(String, String)] = [
            ("Total Expenses:", CurrencyFormatter.string(from: total)),
            ("Number of Expenses:", "\(expenses.count)")
        ]

        for (label, value) in summaryLines {
            (label as NSString).draw(
                in: CGRect(x: margin, y: y, width: 160, height: 16),
                withAttributes: [.font: totalFont]
            )
            (value as NSString).draw(
                in: CGRect(x: margin + 160, y: y, width: 200, height: 16),
                withAttributes: [.font: bodyFont]
            )
            y += 16
        }

        y += 4
        // Category breakdown
        let grouped = Dictionary(grouping: expenses) { $0.category?.id }
        let sortedGroups = grouped.sorted { lhs, rhs in
            let lhsOrder = lhs.value.first?.category?.sortOrder ?? Int.max
            let rhsOrder = rhs.value.first?.category?.sortOrder ?? Int.max
            return lhsOrder < rhsOrder
        }
        for (_, items) in sortedGroups {
            let categoryName = items.first?.category?.name ?? "Uncategorized"
            let subtotal = items.reduce(Decimal.zero) { $0 + $1.amount }
            let line = "  \(categoryName): \(CurrencyFormatter.string(from: subtotal)) (\(items.count))"
            (line as NSString).draw(
                in: CGRect(x: margin, y: y, width: contentWidth, height: 14),
                withAttributes: [.font: bodyFont, .foregroundColor: UIColor.darkGray]
            )
            y += 14
        }
        return y
    }

    // MARK: - Table Drawing

    private static func drawTableHeader(cursorY: CGFloat) -> CGFloat {
        var y = cursorY
        drawHorizontalLine(y: y)
        y += 4
        for col in columns {
            let style = NSMutableParagraphStyle()
            style.alignment = col.title == "Amount" ? .right : .left
            (col.title as NSString).draw(
                in: CGRect(x: col.x, y: y, width: col.width, height: 14),
                withAttributes: [.font: headerFont, .paragraphStyle: style]
            )
        }
        y += 16
        drawHorizontalLine(y: y)
        y += 4
        return y
    }

    private static func drawExpenseRow(
        expense: Expense,
        cursorY: CGFloat
    ) -> CGFloat {
        let values = [
            expense.date.displayString,
            expense.category?.name ?? "Uncategorized",
            expense.merchant,
            expense.client,
            CurrencyFormatter.string(from: expense.amount)
        ]
        for (index, col) in columns.enumerated() {
            let style = NSMutableParagraphStyle()
            style.alignment = col.title == "Amount" ? .right : .left
            style.lineBreakMode = .byTruncatingTail
            (values[index] as NSString).draw(
                in: CGRect(x: col.x, y: cursorY, width: col.width, height: 14),
                withAttributes: [.font: bodyFont, .paragraphStyle: style]
            )
        }
        return cursorY + 16
    }

    private static func drawSubtotal(
        label: String,
        amount: Decimal,
        cursorY: CGFloat
    ) -> CGFloat {
        var y = cursorY + 2
        drawHorizontalLine(y: y, dashed: true)
        y += 4
        (label as NSString).draw(
            in: CGRect(x: margin, y: y, width: 300, height: 14),
            withAttributes: [.font: headerFont]
        )
        let amountCol = columns.last!
        let style = NSMutableParagraphStyle()
        style.alignment = .right
        (CurrencyFormatter.string(from: amount) as NSString).draw(
            in: CGRect(x: amountCol.x, y: y, width: amountCol.width, height: 14),
            withAttributes: [.font: headerFont, .paragraphStyle: style]
        )
        y += 18
        return y
    }

    private static func drawGrandTotal(
        amount: Decimal,
        cursorY: CGFloat
    ) -> CGFloat {
        var y = cursorY + 4
        drawHorizontalLine(y: y)
        y += 2
        drawHorizontalLine(y: y)
        y += 6
        ("Grand Total" as NSString).draw(
            in: CGRect(x: margin, y: y, width: 300, height: 16),
            withAttributes: [.font: totalFont]
        )
        let amountCol = columns.last!
        let style = NSMutableParagraphStyle()
        style.alignment = .right
        (CurrencyFormatter.string(from: amount) as NSString).draw(
            in: CGRect(x: amountCol.x, y: y, width: amountCol.width, height: 16),
            withAttributes: [.font: totalFont, .paragraphStyle: style]
        )
        return y + 20
    }

    // MARK: - Footer

    private static func drawFooter(pageNumber: Int) {
        let text = "Page \(pageNumber)"
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        (text as NSString).draw(
            in: CGRect(
                x: margin, y: pageHeight - 40,
                width: contentWidth, height: 14
            ),
            withAttributes: [
                .font: subtitleFont,
                .foregroundColor: UIColor.gray,
                .paragraphStyle: style
            ]
        )
    }

    // MARK: - Helpers

    private static func drawHorizontalLine(
        y: CGFloat, dashed: Bool = false
    ) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.saveGState()
        ctx.setStrokeColor(UIColor.gray.cgColor)
        ctx.setLineWidth(0.5)
        if dashed {
            ctx.setLineDash(phase: 0, lengths: [4, 2])
        }
        ctx.move(to: CGPoint(x: margin, y: y))
        ctx.addLine(to: CGPoint(x: pageWidth - margin, y: y))
        ctx.strokePath()
        ctx.restoreGState()
    }

    private static func fileTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter.string(from: Date())
    }
}
