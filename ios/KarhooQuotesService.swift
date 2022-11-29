import KarhooSDK

class KarhooQuotesService {
    static let QUOTE_SEARCH_FAILED = "QUOTE_SEARCH_FAILED";
    
    static func quoteSearch(_ quoteSearchData: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
        let quoteSearch = QuoteSearch(
            origin: quoteSearchData["origin"] as! LocationInfo,
            destination: quoteSearchData["destination"] as! LocationInfo,
            dateScheduled: quoteSearchData["dateScheduled"] as? Date
        );
    }
}
