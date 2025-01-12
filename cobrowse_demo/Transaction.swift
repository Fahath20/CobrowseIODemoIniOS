//
//  Transaction.swift
//  cobrowse_demo
//
//  Created by Fahath Rajak on 1/11/25.
//

import Foundation

// Model structs
struct User: Codable {
    let userId: Int
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phoneNumber = "phone_number"
        case createdAt = "created_at"
    }
}

struct Account: Codable {
    let accountId: Int
    let accountType: String
    let balance: Double
    let createdAt: String
    let transactions: [Transaction]

    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case accountType = "account_type"
        case balance
        case createdAt = "created_at"
        case transactions
    }
}

struct Transaction: Codable, Hashable {
    let transactionId: Int
    let transactionType: String
    let amount: Double
    let transactionDate: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case transactionType = "transaction_type"
        case amount
        case transactionDate = "transaction_date"
        case description
    }
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = dateFormatter.date(from: transactionDate)
        let formattedDate = dateFormatter.string(from: date ?? Date())
        return formattedDate
    }
}

struct AccountTransactionsResponse: Codable {
    let user: User
    let accounts: [Account]
}

struct AccountTransactions {
    // Function to load the JSON file from the app bundle
    static func loadJSONFromFile(filename: String) -> Data? {
        // Ensure the file exists in the app bundle
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("File not found")
            return nil
        }

        do {
            // Read the contents of the file into Data
            let data = try Data(contentsOf: fileURL)
            return data
        } catch {
            print("Failed to load data from file: \(error)")
            return nil
        }
    }

    // Function to parse JSON and print the results
    static func parseJSONFromFile() -> AccountTransactionsResponse? {
                
        // Load JSON data from the file
        if let data = loadJSONFromFile(filename: "transactions") {
            let decoder = JSONDecoder()
            
            do {
                // Decode the JSON data into our Swift structs
                let response = try decoder.decode(AccountTransactionsResponse.self, from: data)
                // Accessing and printing the data
                print("User Info:")
                print("Name: \(response.user.firstName) \(response.user.lastName)")
                print("Email: \(response.user.email)")
                
                for account in response.accounts {
                    print("\nAccount Type: \(account.accountType)")
                    print("Balance: \(account.balance)")
                    
                    for transaction in account.transactions {
                        print("\nTransaction ID: \(transaction.transactionId)")
                        print("Type: \(transaction.transactionType)")
                        print("Amount: \(transaction.amount)")
                        print("Date: \(transaction.transactionDate)")
                        print("Description: \(transaction.description)")
                    }
                }
                
                return response
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        
        return nil
    }

}
