import Foundation

struct InlineLinkParser {
    func parse(_ input: TextCursor) -> TextResult<Link?> {
        let openParen = input.parse("(")
        guard openParen.value.isNotEmpty else {
            return input.noMatch(nil)
        }
        
        let spaces1Result = SpacesAndNewlineParser().parse(openParen.remaining)
        
        let destinationResult = LinkDestinationParser().parse(spaces1Result.remaining)

        let titleResult = parseOptionalTitle(destinationResult.remaining)

        let spaces2Result = SpacesAndNewlineParser().parse(titleResult.remaining)

        let closeParen = spaces2Result.remaining.parse(")")
        guard closeParen.value.isNotEmpty else {
            return input.noMatch(nil)
        }

        let url = destinationResult.value ?? ""
        return TextResult(remaining: closeParen.remaining,
                          value: Link(title: titleResult.value, url: url),
                          valueLocation: openParen.valueLocation)
    }
}

private extension InlineLinkParser {
    func parseOptionalTitle(_ input: TextCursor) -> TextResult<String> {
        let spacesResult = SpacesAndNewlineParser().parse(input)
        
        // If spaces, then could be a title
        guard spacesResult.value.isNotEmpty else {
            return input.noMatch("")
        }
        
        let titleResult = LinkTitleParser().parse(spacesResult.remaining)
        guard titleResult.value.isNotEmpty else {
            return input.noMatch("")
        }
        return titleResult
    }
}
