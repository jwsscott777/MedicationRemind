//
//  ContentView.swift
//  MedicationRemind
//
//  Created by JWSScott777 on 12/4/20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: PillReminderViewModel
       
       var body: some View {
           ZStack {
               VStack {
                   Spacer(minLength: 95)
                   /// Show 'add a pill' screen
                   if viewModel.navigationStyle == .addPillReminder {
                       AddPillView(viewModel: viewModel.pillViewModel, baseViewModel: viewModel)
                       
                   /// Show main 'Today' screen
                   } else {
                       /// Show no reminders view when necessary
                       if viewModel.hasReminders == false {
                           NoRemindersView()
                           
                       /// Show a list of pill reminders
                       } else {
                           RemindersListView(viewModel: viewModel)
                       }
                   }
               }
               
               /// Navigation view
               VStack {
                   CustomNavigationView(viewModel: viewModel)
                   Spacer()
               }
           }
           .onAppear(perform: {
               self.viewModel.getUpdatedRemindersList()
           })
           .background(viewModel.hasReminders ? Color(#colorLiteral(red: 0.7098039216, green: 0.7019607843, blue: 0.3607843137, alpha: 1)) : Color(#colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)))
           .edgesIgnoringSafeArea(.bottom)
       }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: PillReminderViewModel())
            .preferredColorScheme(.dark)
    }
}
