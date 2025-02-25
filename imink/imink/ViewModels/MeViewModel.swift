//
//  MeViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/10/14.
//

import Foundation
import Combine
import WebKit

class MeViewModel: ObservableObject {
    
    @Published var isLogined: Bool = false
    @Published var isLoading: Bool = false
    @Published var records: Records?
    @Published var nicknameAndIcons: NicknameAndIcon?
    
    private var cancelBag = Set<AnyCancellable>()
    
    init(isLogined: Bool) {
        self.isLogined = isLogined
        
        if (isLogined) {
            self.loadUserInfo()
        }
    }
    
    func loadUserInfo() {
        isLoading = true
        
        Splatoon2API.records
            .request()
            .receive(on: DispatchQueue.main)
            .compactMap { (data: Data) -> Records? in
                // Cache
                AppUserDefaults.shared.splatoon2RecordsData = data
                return data.decode(Records.self)
            }
            .flatMap { [weak self] records -> AnyPublisher<Data, Error> in
                self?.records = records
                return Splatoon2API.nicknameAndIcon(id: records.records.player.principalId)
                    .request()
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
            .compactMap { data -> NicknameAndIcon? in
                // Cache
                AppUserDefaults.shared.splatoon2NicknameAndIconData = data
                return data.decode(NicknameAndIcon.self)
            }
            .sink { [weak self] error in
                self?.isLoading = false
            } receiveValue: { [weak self] nicknameAndIconData in
                self?.isLoading = false
                self?.nicknameAndIcons = nicknameAndIconData
            }
            .store(in: &cancelBag)
            
        loadCacheData()
    }
    
    func loadCacheData() {
        guard let recordsData = AppUserDefaults.shared.splatoon2RecordsData,
              let nicknameAndIconData = AppUserDefaults.shared.splatoon2NicknameAndIconData else {
            return
        }
        
        records = recordsData.decode(Records.self)
        nicknameAndIcons = nicknameAndIconData.decode(NicknameAndIcon.self)
    }
    
    func logOut() {
        AppUserDefaults.shared.loginToken = nil
        AppUserDefaults.shared.naUser = nil
        AppUserDefaults.shared.sp2PrincipalId = nil
        
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
