//
//  HomePage.swift
//  imink
//
//  Created by Jone Wang on 2020/10/1.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomePage: View {
            
    @StateObject private var viewModel: HomeViewModel
    
    @State private var scheduleType = 0
    @State private var vdChartViewHeight: CGFloat = 0
    @State private var vdChartLastBlockWidth: CGFloat = 0
    
    init(isLogined: Bool) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(isLogined: isLogined))
    }
    
    private let scheduleTimeFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    Spacer()
                    
                    VStack {
                        VStack {
                            VStack(alignment: .leading, spacing: 0) {
                                
                                HStack(alignment: .firstTextBaseline) {
                                    
                                    Text("Today")
                                        .sp1Font(size: 22, color: AppColor.appLabelColor)
                                    
                                    Text("(\(viewModel.resetHour):00 \("reset".localized))")
                                        .sp2Font(color: Color.secondary)
                                    
                                }
                                
                                TodayView(today: viewModel.today)
                                
                            }
                            .padding(.top)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                
                                HStack(alignment: .firstTextBaseline) {
                                    
                                    Text("Results")
                                        .sp1Font(size: 22, color: AppColor.appLabelColor)
                                    
                                    Text("(\(NSLocalizedString("Last 500", comment: "")))")
                                        .sp2Font(color: Color.secondary)
                                    
                                }
                                
                                HStack {
                                    Spacer()
                                    
                                    Text("Last 50")
                                        .sp2Font(size: 8, color: Color.secondary)
                                        .minimumScaleFactor(0.5)
                                        .frame(width: vdChartLastBlockWidth)
                                }
                                .frame(height: 20)
                                
                                VDGridView(
                                    data: viewModel.vdWithLast500,
                                    height: $vdChartViewHeight,
                                    lastBlockWidth: $vdChartLastBlockWidth
                                )
                                .frame(height: vdChartViewHeight)
                                
                            }
                            .padding(.top)
                        }
                        .modifier(LoginViewModifier(isLogined: viewModel.isLogined, iconName: "TabBarHome"))
                        
                        if let festival = viewModel.activeFestivals?.festivals.first {
                            VStack(alignment: .leading, spacing: 0) {
                                
                                Text("Splatfest")
                                    .sp1Font(size: 22, color: AppColor.appLabelColor)
                                
                                ZStack {
                                    HStack(spacing: 0) {
                                        Rectangle()
                                            .fill(festival.colors.alpha.color)
                                        Rectangle()
                                            .fill(festival.colors.bravo.color)
                                    }
                                    
                                    VStack {
                                        HStack(spacing: 0) {
                                            WebImage(url: festival.images.alpha)
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                                .padding(.trailing, 8)
                                            
                                            Text(festival.names.alphaShort)
                                                .sp1Font(size: 14)
                                            
                                            Spacer()
                                            
                                            Text(festival.names.bravoShort)
                                                .sp1Font(size: 14)
                                            
                                            WebImage(url: festival.images.bravo)
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                                .padding(.leading, 8)
                                        }
                                        
                                        Text("\(festival.times.start, formatter: scheduleTimeFormat) - \(festival.times.end, formatter: scheduleTimeFormat)")
                                            .sp2Font()
                                            .padding(.bottom, 4)
                                    }
                                    .padding(8)
                                }
                                .frame(height: 70)
                                .background(AppColor.listItemBackgroundColor)
                                .continuousCornerRadius(10)
                                .padding(.top)
                            }
                            .padding(.top)
                        }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            
                            Text("Schedule")
                                .sp1Font(size: 22, color: AppColor.appLabelColor)
                            
                            VStack {
                                Picker(selection: $scheduleType, label: Text("Picker"), content: {
                                    Text("Battle").tag(0)
                                    Text("Salmon Run").tag(1)
                                })
                                .pickerStyle(SegmentedPickerStyle())
                                .frame(width: 230)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                            
                            if scheduleType == 0 {
                                if let schedules = viewModel.schedules {
                                    ScheduleView(
                                        regularSchedules: schedules.regular,
                                        gachiSchedules: schedules.gachi,
                                        leagueSchedules: schedules.league
                                    )
                                    .padding(.top)
                                } else {
                                    makeLoadingView()
                                }
                            } else {
                                if let salmonRunSchedules = viewModel.salmonRunSchedules {
                                    SalmonRunScheduleView(
                                        schedules: salmonRunSchedules
                                    )
                                    .padding(.top)
                                } else {
                                    makeLoadingView()
                                }
                            }
                            
                        }
                        .padding([.top, .bottom])
                        .animation(.default)
                        
                        Spacer()
                    }
                    .frame(maxWidth: 500)
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
            }
            .background(AppColor.listBackgroundColor)
            .navigationBarTitle("Home", displayMode: .inline)
            .navigationBarItems(trailing: makeNavigationBarItems())
            .navigationBarHidden(false)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func makeLoadingView() -> some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .padding()
        .background(AppColor.listItemBackgroundColor)
        .continuousCornerRadius(10)
        .padding(.top)
    }
    
    func makeNavigationBarItems() -> some View {
        HStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Button(action: {
                    viewModel.updateSchedules()
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
            }
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage(isLogined: true)
            .previewLayout(.sizeThatFits)
            .frame(width: 1024, height: 768)
        
        HomePage(isLogined: true)
            .previewLayout(.sizeThatFits)
            .frame(width: 400, height: 768)
    }
}
