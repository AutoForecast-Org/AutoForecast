//
//  FeedbackView.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import MessageUI

struct FeedbackView: View {
    @State private var subject: String = ""
    @State private var message: String = ""
    @State private var showMailComposer = false
    @State private var showMailErrorAlert = false

    var body: some View {
        Form {
            Section(header: Text("Oggetto")) {
                TextField("Inserisci l'oggetto", text: $subject)
            }
            
            Section(header: Text("Messaggio")) {
                TextEditor(text: $message)
                    .frame(minHeight: 150)
            }
            
            Section {
                Button {
                    if MFMailComposeViewController.canSendMail() {
                        showMailComposer = true
                    } else {
                        showMailErrorAlert = true
                    }
                } label: {
                    Label("Invia feedback", systemImage: "paperplane.fill")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(ColorLayout.primary.auto)
                }
                .disabled(subject.isEmpty || message.isEmpty)
            }
        }
        .navigationTitle("Invia feedback")
        .sheet(isPresented: $showMailComposer) {
            MailComposer(subject: subject, body: message)
        }
        .alert("Nessun account email configurato", isPresented: $showMailErrorAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

struct MailComposer: UIViewControllerRepresentable {
    var subject: String
    var body: String
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        vc.setToRecipients(["forecastauto@gmail.com"])
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            controller.dismiss(animated: true)
        }
    }
}
