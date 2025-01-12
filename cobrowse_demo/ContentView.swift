//
//  ContentView.swift
//  cobrowse_demo
//
//  Created by Fahath Rajak on 1/10/25.
//

import SwiftUI
import CobrowseIO

class AccountViewModel: NSObject, ObservableObject {

    @Published var checkingTransactions = [Transaction]()
    @Published var savingsTransactions = [Transaction]()
    @Published var userName = "User"
    var email = ""

    override init() {
        super.init()
        
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
        
        if let email = response?.user.email {
            self.email = email
        }
    }
}



struct ContentView: View {
    @ObservedObject var viewModel: AccountViewModel
    @ObservedObject var cobrowseManager: CobrowseManager
    @State var showCode: Bool
    @State var agentCode: String?
    
    init(viewModel: AccountViewModel = AccountViewModel(), cobrowseManager: CobrowseManager = CobrowseManager(), showCode: Bool = false, agentCode: String? = nil) {
        self.viewModel = viewModel
        self.cobrowseManager = cobrowseManager
        self.showCode = showCode
        self.agentCode = agentCode
        
        self.cobrowseManager.initSession(userEmail: self.viewModel.email, capabilities: ["laser"])
    }

    var body: some View {
        
        NavigationStack {
            VStack {
                
                HStack {
                    Text("Welcome!, Mr. \(viewModel.userName)")
                        .bold()
                    Spacer()
                    
                    if cobrowseManager.isSessionActive {
                        Button("Stop Cobrowse session") {
                            cobrowseManager.endSession { result in
                                print(result)
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(.pink)
                    } else {
                        Button("Customer Support") {
                            cobrowseManager.establishSessionFromUser(userEmail: viewModel.email, capabilities: ["laser", "drawing"]) { agentCode in
                                self.agentCode = agentCode
                                self.showCode = true
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
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
            isPresented: $cobrowseManager.sessionRequested,
            presenting: cobrowseManager.cobrowseSession
        ) { session in
            Button("Allow", role: .none) {
                cobrowseManager.activateSession()
            }
            Button("Cancel", role: .cancel) {
                cobrowseManager.endSession { result in
                    print(result)
                }
            }
        } message: { session in
            Text("A Support agent has requested to use this app with you. Do you wish to allow this?.")
        }
        .alert(
            Text("6 digit code"),
            isPresented: $showCode,
            presenting: agentCode
        ) { agentCode in
            Button("Ok", role: .none) {}
        } message: { agentCode in
            Text(agentCode)
        }
    }
}

struct TransactionsView: View {
    
    @ObservedObject var viewModel = AccountViewModel()

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
