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
        
        self.cobrowseManager.initSession(userEmail: self.viewModel.email, capabilities: ["cursor", "drawing", "laser"])
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
                            // Agent cursor movement will be visible to user
                            // Agent can point something on the user screen
                            // Agent can draw on user screen
                            cobrowseManager.establishSessionFromUser(userEmail: viewModel.email, capabilities: ["cursor", "drawing", "laser"]) { agentCode in
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
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
            
            NavigationLink(value: "loanView") {
                Text("Apply Loan")
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
            .navigationDestination(for: String.self) { view in
                if view == "transactions" {
                    TransactionsView()
                        .redacted()
                } else if view == "loanView" {
                    ApplyLoanView()
                        .unredacted()
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

struct ApplyLoanView: View {
    @State var loanAmount: String = ""
    @State var reason: String = ""

    var body: some View {
        VStack {
            Text("Apply Loan")
                .padding()
                .bold()
            TextField("Amount", text: $loanAmount)
                .padding()
                .redacted()
            TextField("Reason for applying loan", text: $reason)
                .padding()
            
            Button("Submit") { print("Submit Clicked") }
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
