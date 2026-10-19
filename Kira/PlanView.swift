//
//  PlanView.swift
//  Kira
//
//  Created by Karyna Budi Sanjaya on 15/10/26.
//

import SwiftUI

struct PlanView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                VStack(alignment: .leading) {
                    Text("Budget Plan")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("April 2025") // To show actual Month/Year
                }
                Spacer()
                Image(systemName: "person.circle")
                    .font(.system(size: 40))
            }
            
            Spacer()
            
            VStack(){
                HStack {
                    Text("Your Balance")
                        .font(.callout)
                    Spacer()
                    Image(systemName: "pencil")
                }
                HStack(alignment: .lastTextBaseline) {
                    Text("Rp 1.270.000") // To show actual remaining balance
                        .font(.title)
                        .fontWeight(.bold)
                    Text("/")
                    Text("5.800.000") // To show actual monthly budget
                    Spacer()
                }
                .fontWeight(.semibold)
                HStack {
                    Spacer()
                    Image(systemName: "plus.circle")
                    Text("Add Expense")
                        .font(.callout)
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(.accentDarkPurple)
                .cornerRadius(12)
            }
            .padding()
            .foregroundStyle(.white)
            .background(.accentPurple)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.accentDarkPurple, lineWidth: 1)
            )
            
            Spacer()
            
            Text("Category")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12){
                CategoryCard(icon: "list.bullet.clipboard.fill", title: "Needs", remaining: 410, budget: 2900, color: .needs, colorLight: .needsLight)
                CategoryCard(icon: "cart.fill", title: "Wants", remaining: 556.8, budget: 2900, color: .wants, colorLight: .wantsLight)
            }
            
            Spacer()
            
            HStack() {
                Text("Recent Expenses")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("Show all")
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
            }
            
            VStack() {
                ExpenseCard(icon: "ticket.fill", title: "Extra iCloud Storage", subCategory: "Sports", amount: 45.210, date: "22 April 2025", color: .wants, colorLight: .wantsLight)
                
                Divider()
                
                ExpenseCard(icon: "bubbles.and.sparkles.fill", title: "Basic Toiletries", subCategory: "Personal Care", amount: 50, date: "22 April 2025", color: .needs, colorLight: .needsLight)
            }
            .padding()
            .background(.white)
            .cornerRadius(12)
            
        }
        .padding()
        .background(.backgroundGray)
    }

}

struct ExpenseCard: View {
    let icon: String
    let title: String
    let subCategory: String
    let amount: Double
    let date: String
    var color: Color = .blue
    var colorLight: Color = .white
    
    var body: some View {
        HStack() {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .padding(10)
                .frame(width: 44, height: 44)
                .background(colorLight)
                .cornerRadius(12)
            
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                Text(subCategory)
                    .font(.subheadline)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Rp \(amount.formatted(.number.locale(Locale(identifier: "id_ID")).precision(.fractionLength(3))))")
                    .fontWeight(.bold)
                Text(date)
                    .font(.caption)
            }
        }
    }
}

struct CategoryCard: View {
    let icon: String
    let title: String
    let remaining: Double
    let budget: Double
    var color: Color = .blue
    var colorLight: Color = .white
    
    var used: Double {
        budget - remaining
    }
    
    var body: some View {
        VStack() {
            HStack(alignment: .top) {
                HStack() {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing){
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Rp \(remaining.formatted(.number.locale(Locale(identifier: "id_ID")).precision(.fractionLength(3))))") // To show actual remaining balance
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }

            }
            ProgressBar(
                value: used,
                total: budget,
                foregroundColor: color,
                backgroundColor: colorLight
            )
            
            HStack {
                Spacer()
                Text("out of Rp \(budget)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .foregroundColor(color)
        .background(.white)
        .cornerRadius(12)
    }
}

struct ProgressBar: View {
    let value: Double
    let total: Double
    var height: CGFloat = 10
    var foregroundColor: Color = .blue
    var backgroundColor: Color = .black
    
    // Clamps the progress ratio between 0.0 and 1.0 to prevent overflow
    private var progressRatio: CGFloat {
        guard total > 0 else { return 0 }
        return min(max(CGFloat(value / total), 0), 1.0)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background Track
                Capsule()
                    .fill(backgroundColor)
                
                // Active Progress
                Capsule()
                    .fill(foregroundColor)
                    .frame(width: geometry.size.width * progressRatio)
            }
        }
        .frame(height: height)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: value)
    }
}

#Preview {
    PlanView()
}
