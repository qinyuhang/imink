//
//  AboutPage.swift
//  imink
//
//  Created by Jone Wang on 2020/10/23.
//

import SwiftUI

struct AboutPage: View {
    
    @State var isShowingMailView = false
    
    var body: some View {
        let contributions = [
            "Jone Wang", "Ryan Lau", "Shaw",
            "Key山", "俐吟", "小傘Emp", "米雪", "ai",
            "ddddxxx", "柏汐", "Padotagi"
        ]
        ScrollView {
            HStack {
                VStack(alignment: .leading, spacing: 32) {
                    Text(String("About imink"))
                        .sp1Font(size: 30, color: AppColor.appLabelColor)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Disclaimer")
                            .sp1Font(size: 22, color: AppColor.appLabelColor)
                        
                        Text("This app is an unofficial companion app that uses the information of SplatNet 2, and is not affiliated or associated with Nintendo.")
                            .sp2Font(size: 14, color: Color.primary.opacity(0.8), lineLimit: 9)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Contributions")
                            .sp1Font(size: 22, color: AppColor.appLabelColor)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(contributions, id: \.self) { name in
                                Text(name)
                                    .sp2Font(size: 14, color: Color.primary.opacity(0.8))
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Thanks")
                            .sp1Font(size: 22, color: AppColor.appLabelColor)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ikaWidget2 / @NexusMine")
                                .sp2Font(size: 14, color: Color.primary.opacity(0.8))
                            
                            Text("splatnet2statink / @frozenpandaman")
                                .sp2Font(size: 14, color: Color.primary.opacity(0.8))
                        }
                        
                        Text("Thank them for providing the necessary algorithm API for account login.")
                            .font(.system(size: 10))
                            .foregroundColor(Color.primary.opacity(0.6))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Feedback")
                            .sp1Font(size: 22, color: AppColor.appLabelColor)
                        
                        HStack {
                            Link(destination: URL(string: "https://t.me/iminkUserGroup")!) {
                                VStack(spacing: 4) {
                                    Text("User Group on Telegram")
                                        .sp2Font(size: 12, color: AppColor.appLabelColor)
                                    Text("https://t.me/iminkUserGroup")
                                        .font(.system(size: 10, weight: .bold))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(AppColor.appLabelColor)
                                }
                                .padding(12)
                                .background(Color.secondarySystemBackground)
                                .continuousCornerRadius(10)
                            }
                            
                            VStack(spacing: 4) {
                                Text("E-mail")
                                    .sp2Font(size: 12, color: AppColor.appLabelColor)
                                Text("i@jone.wang")
                                    .font(.system(size: 10, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(AppColor.appLabelColor)
                            }
                            .padding(12)
                            .background(Color.secondarySystemBackground)
                            .continuousCornerRadius(10)
                            .onTapGesture {
                                if MailView.canSendMail() {
                                    self.isShowingMailView.toggle()
                                }
                            }
                        }
                    }
                    
                }
                .padding([.top, .bottom], 20)
                
                Spacer()
            }
            .padding()
            .padding(.leading, 12)
        }
        .sheet(isPresented: $isShowingMailView) {
            MailView(isShowing: self.$isShowingMailView, recipient: "i@jone.wang")
        }
    }
}

struct AboutPage_Previews: PreviewProvider {
    static var previews: some View {
        AboutPage()
        
        AboutPage()
            .preferredColorScheme(.dark)
    }
}
