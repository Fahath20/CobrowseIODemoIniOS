//
//  ContentView.swift
//  cobrowse_demo
//
//  Created by Fahath Rajak on 1/10/25.
//

import SwiftUI
import CobrowseIO

class TransactionViewModel: NSObject, ObservableObject, CobrowseIODelegate {

    
    @Published var sessionState = ""
    @Published var checkingTransactions = [Transaction]()
    @Published var savingsTransactions = [Transaction]()
    @Published var userName = "User"
    @Published var handleRemoteRequest = false
    @Published var cobrowseSession: CBIOSession? = nil

    override init() {
        super.init()
        CobrowseIO.instance().delegate = self
        
        let response = AccountTransactions.parseJSONFromFile()
        
        if let transactions = response?
            .accounts
            .filter({ $0.accountType == "Checking" })
            .first?
            .transactions {
            self.checkingTransactions = transactions
        }
        
        if let transactions = response?
            .accounts
            .filter({ $0.accountType == "Savings" })
            .first?
            .transactions {
            self.savingsTransactions = transactions
        }
        
        if let firstName = response?.user.firstName,
           let lastName = response?.user.lastName {
            self.userName = firstName + " " + lastName
        }
    }
    
    func startSession() {
        CobrowseIO.instance().start()
//        CobrowseIO.instance().createSession { error, session in
//            if let error {
//                print("Error occured", error)
//            } else {
//                print(session ?? "No Session created")
//            }
//        }
    }
    
    func stopSession() {
        CobrowseIO.instance().currentSession()?.end()
    }
    
    func cobrowseSessionDidLoad(_ session: CBIOSession) {
        sessionState = session.state()
    }
    
    func cobrowseSessionDidUpdate(_ session: CBIOSession) {
        sessionState = session.state()
    }
    
    func cobrowseSessionDidEnd(_ session: CBIOSession) {
        sessionState = session.state()
    }
    
    func cobrowseHandleSessionRequest(_ session: CBIOSession) {
        handleRemoteRequest = true
        cobrowseSession = session
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = TransactionViewModel()
    
    var body: some View {
        
        NavigationStack {
            VStack {
                
                HStack {
                    Text("Welcome!, Mr. \(viewModel.userName)")
                        .bold()
                    Spacer()
                    
                    if viewModel.sessionState == "active" {
                        Button("Stop Cobrowse session") {
                            viewModel.stopSession()
                        }
                        .buttonStyle(.bordered)
                        .tint(.pink)
                    }
                }
                .padding(.bottom)
                
                HStack {
                    Text("Account Number")
                    Spacer()
                    Text("123456789")
                        .redacted()
                }
                
                
                HStack {
                    Text("Card Number")
                    Spacer()
                    Text("1234 5678 9801 2345")
                        .redacted()
                }
                
                HStack {
                    Text("Phone Number")
                    Spacer()
                    Text("210-99-9999")
                        .redacted()
                }
            }
            .padding()
            
            Spacer()
            NavigationLink(value: "transactions") {
                Text("Show Transactions")
            }
            .navigationDestination(for: String.self) { view in
                if view == "transactions" {
                    TransactionsView()
                        .redacted()
                }
            }
        }
        .unredacted()
        .alert(
            Text("Support request"),
            isPresented: $viewModel.handleRemoteRequest,
            presenting: viewModel.cobrowseSession
        ) { session in
            Button("Allow", role: .none) {
                viewModel.cobrowseSession?.activate()
            }
            Button("Cancel", role: .cancel) {
                viewModel.cobrowseSession?.end()
            }
        } message: { session in
            Text("A Support agent has requested to use this app with you. Do you wish to allow this?.")
        }
    }
}

struct TransactionsView: View {
    
    @ObservedObject var viewModel = TransactionViewModel()

    var body: some View {
        VStack {
            Text("Transactions")
                .padding()
            
            List {
                // Checking Section
                Section(header: Text("Checking")) {
                    ForEach(viewModel.checkingTransactions, id: \.self) { transaction in
                        transactionView(transaction: transaction)
                    }
                }
                
                // Savings Section
                Section(header: Text("Savings")) {
                    ForEach(viewModel.savingsTransactions, id: \.self) { transaction in
                        transactionView(transaction: transaction)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func transactionView(transaction: Transaction) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(transaction.description)")
                Text("\(transaction.formattedDate)")
            }
            Spacer()
            Text("\(transaction.amount.formatted(.currency(code: "USD")))")
                .bold()
                .redacted()
        }
    }
}

#Preview {
    ContentView()
}
