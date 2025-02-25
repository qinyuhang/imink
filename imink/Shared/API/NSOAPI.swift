//
//  NSOAPI.swift
//  imink
//
//  Created by Jone Wang on 2021/3/12.
//

import Foundation
import CryptoKit

enum NSOAPI {
    case authorize(codeVerifier: String)
    case sessionToken(codeVerifier: String, sessionTokenCode: String)
    case token(sessionToken: String)
    case me(accessToken: String)
    case login(requestId: String,
               naIdToken: String,
               naBirthday: String,
               naCountry: String,
               language: String,
               timestamp: String,
               f: String)
    case getWebServiceToken(
            webApiServerToken: String,
            requestId: String,
            registrationToken: String,
            timestamp: String,
            f: String)
    
    // api docs: https://github.com/frozenpandaman/splatnet2statink/wiki/api-docs
    case s2s(naIdToken: String, timestamp: String)
    case f(naIdToken: String, requestId: String, timestamp: String, s2sHash: String, iid: Iid)
}

extension NSOAPI: APITargetType {
    private static let clientId = "71b963c1b7b6d119"
    public static let clientUrlScheme = "npf\(NSOAPI.clientId)"
    private static let clientVersion = "1.10.0"
    private static let gameServiceId = "5741031244955648"
    private static let flapgAPIVersion = "3"
    
    internal enum Iid: String {
        case nso
        case app
    }
    
    var baseURL: URL {
        switch self {
        case .authorize,
             .sessionToken,
             .token:
            return URL(string: "https://accounts.nintendo.com/connect/1.0.0")!
        case .me:
            return URL(string: "https://api.accounts.nintendo.com/2.0.0")!
        case .login:
            return URL(string: "https://api-lp1.znc.srv.nintendo.net/v1")!
        case .getWebServiceToken:
            return URL(string: "https://api-lp1.znc.srv.nintendo.net/v2")!
        case .s2s:
            return URL(string: "https://elifessler.com/s2s/api")!
        case .f:
            return URL(string: "https://flapg.com/ika2/api/login?public")!
        }
    }
    
    var path: String {
        switch self {
        case .authorize:
            return "/authorize"
        case .sessionToken:
            return "/api/session_token"
        case .token:
            return "/api/token"
        case .me:
            return "/users/me"
        case .login:
            return "/Account/Login"
        case .getWebServiceToken:
            return "/Game/GetWebServiceToken"
        case .s2s:
            return "/gen2"
        case .f:
            return ""
        }
    }
    
    var method: APIMethod {
        switch self {
        case .authorize,
             .me,
             .f:
            return .get
        case .sessionToken,
             .token,
             .login,
             .getWebServiceToken,
             .s2s:
            return .post
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .authorize:
            return [
                "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 14_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Mobile/15E148 Safari/604.1"
            ]
        case .sessionToken,
             .token:
            return [
                "Accept": "application/json",
                "User-Agent" : "OnlineLounge/\(NSOAPI.clientVersion) NASDKAPI iOS"
            ]
        case .me(let accessToken):
            return [
                "Accept": "application/json",
                "User-Agent": "OnlineLounge/\(NSOAPI.clientVersion) NASDKAPI iOS",
                "Authorization": "Bearer \(accessToken)",
                "Accept-Encoding": "gzip, deflate, br"
            ]
        case .login:
            return [
                "Accept": "application/json",
                "User-Agent": "com.nintendo.znca/\(NSOAPI.clientVersion) (iOS/14.2)",
                "Authorization": "Bearer",
                "X-Platform": "Android",
                "X-ProductVersion": NSOAPI.clientVersion,
                "Accept-Encoding": "gzip, deflate, br"
            ]
        case .getWebServiceToken(let webApiServerToken, _, _, _, _):
            return [
                "User-Agent": "com.nintendo.znca/\(NSOAPI.clientVersion) (iOS/14.2)",
                "Authorization": "Bearer \(webApiServerToken)",
                "x-platform": "Android",
                "X-ProductVersion": NSOAPI.clientVersion,
                "Accept-Encoding": "gzip, deflate, br"
            ]
        case .s2s:
            return [
                "User-Agent": "imink/\(Bundle.main.appVersionShort)"
            ]
        case .f(let naIdToken, let requestId, let timestamp, let s2sHash, let iid):
            return [
                "x-token": naIdToken,
                "x-time": "\(timestamp)",
                "x-guid": requestId,
                "x-hash": s2sHash,
                "x-ver": NSOAPI.flapgAPIVersion,
                "x-iid": iid.rawValue
            ]
        }
    }
    
    var querys: [(String, String?)]? {
        switch self {
        case .authorize(let codeVerifier):
            let state = NSOHash.urandom(length: 36).base64EncodedString

            let codeDigest = SHA256.hash(
                data: codeVerifier
                    .replacingOccurrences(of: "=", with: "")
                    .data(using: .utf8)!
            )
            let codeChallenge = Data(codeDigest)
                .base64EncodedString
                .replacingOccurrences(of: "=", with: "")
            
            return [
                ("state", state),
                ("redirect_uri", "\(NSOAPI.clientUrlScheme)://auth"),
                ("client_id", NSOAPI.clientId),
                ("scope", "openid user user.birthday user.mii user.screenName"),
                ("response_type", "session_token_code"),
                ("session_token_code_challenge", codeChallenge),
                ("session_token_code_challenge_method", "S256"),
                ("theme", "login_form")
            ]
        default:
            return nil
        }
    }
    
    var data: MediaType? {
        switch self {
        case .sessionToken(let codeVerifier, let sessionTokenCode):
            let codeVerifier = codeVerifier.replacingOccurrences(of: "=", with: "")
            return .form([
                ("client_id", NSOAPI.clientId),
                ("session_token_code", sessionTokenCode),
                ("session_token_code_verifier", codeVerifier)
            ])
        case .token(let sessionToken):
            return .jsonData([
                "client_id": NSOAPI.clientId,
                "session_token": sessionToken,
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer-session-token"
            ])
        case .login(let requestId,
                    let naIdToken,
                    let naBirthday,
                    let naCountry,
                    let language,
                    let timestamp,
                    let f):
            return .jsonData([
                "parameter": [
                    "requestId": requestId,
                    "naIdToken": naIdToken,
                    "naBirthday": naBirthday,
                    "naCountry": naCountry,
                    "timestamp": "\(timestamp)",
                    "language": language,
                    "f": f,
                ]
            ])
        case .getWebServiceToken(_, let requestId, let registrationToken, let timestamp, let f):
            return .jsonData([
                "parameter": [
                    "id": NSOAPI.gameServiceId,
                    "requestId": requestId,
                    "registrationToken": registrationToken,
                    "timestamp": "\(timestamp)",
                    "f": f,
                ]
            ])
        case .s2s(let naIdToken, let timestamp):
            return .form([
                ("naIdToken", naIdToken),
                ("timestamp", "\(timestamp)")
            ])
        default:
            return nil
        }
    }
}
