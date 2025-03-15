//
//  ContentView.swift
//  Habit Tracker
//
//  Created by Lorenzo Viray on 3/10/25.
//

// Notes:
// -ZStacks use for layering components.
// -Computed properties use {} while stored properties (constant values) use =.
// -Use .frame/.padding/.offset() for positioning.
// -Cmd + option + Enter opens content view.
// -type? make a variable optionally hold type or nil.
// -@State mutable keyword
// -Use .buttonStyle(.plain) for image interactable buttons
// -Displaying variable in text, just use \()

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var currentDate : Date = Calendar.current.startOfDay(for: Date())
    private var year : String {currentDate.formatted(.dateTime.year(.defaultDigits))}
    private var month : String {currentDate.formatted(.dateTime.month(.wide))}
    private var day : String {currentDate.formatted(.dateTime.day(.defaultDigits))}
    
    @State private var habits : [(String, Bool)] = []
    @State private var editIndex : Int? = nil
    @FocusState private var isEditing: Bool
    
    @State private var Streak : Int = 0
    @State private var lastStreakDate : Date? = nil
    
    
    var body: some View {
        ZStack {
            // Background
            Image("Background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
            // Date
            HStack {
                Text("\(month)")
                    .fontDesign(.rounded)
                    .foregroundColor(.accent)
                    .font(.system(size: 24, weight: .bold))
                    .padding(.bottom, 180)
                Text("\(day)")
                    .fontDesign(.rounded)
                    .foregroundColor(.accent)
                    .font(.system(size: 150, weight: .bold))
                Text("\(year)")
                    .fontDesign(.rounded)
                    .foregroundColor(.accent)
                    .font(.system(size: 24, weight: .bold))
                    .padding(.bottom, 180)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(EdgeInsets(top: 100, leading: 0, bottom: 0, trailing: 0))
            .onAppear{Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in currentDate = Calendar.current.startOfDay(for: Date())}} // Dynamically changes date
            
            // App
            RoundedRectangle(cornerRadius: 25)
                .fill(.accent)
                .frame(width: 350, height: 486)
                .overlay(
                    List {
                        ForEach(habits.indices, id: \.self) { index in
                            ZStack{
                                Image("Taskbar")
                                    .resizable()
                                    
                                
                                if editIndex == index {
                                    ScrollView {
                                        TextField("Enter New Habit", text: $habits[index].0)
                                            .fontDesign(.rounded)
                                            .foregroundColor(.accentColor2)
                                            .font(.system(size: 14, weight: .bold))
                                            .multilineTextAlignment(.center)
                                            .focused($isEditing)
                                            .onAppear{isEditing = true}
                                            .onSubmit {
                                                if habits[index].0.isEmpty {
                                                    habits.remove(at: index)
                                                }
                                                editIndex = nil
                                                isEditing = false
                                                saveHabits()
                                            }
                                            
                                    }
                                    .frame(width: 180, height: 20)
                                    .padding(EdgeInsets(top: 0, leading: 35, bottom: 2, trailing: 0))
                                    Image("Editpencil")
                                        .frame(width: 30, height: 30)
                                        .padding(.leading, 230)
                                } else {
                                    ScrollView{
                                        Text(habits[index].0)
                                            .fontDesign(.rounded)
                                            .foregroundColor(.accentColor2)
                                            .font(.system(size: 14, weight: .bold))
                                            .multilineTextAlignment(.center)
                                            .onTapGesture(count: 2) {
                                                if !habits[index].1{
                                                    editIndex = index
                                                    isEditing = true
                                                }
                                            }
                                            .strikethrough(habits[index].1)
                                            
                                    }
                                    .frame(width: 180, height: 20)
                                    .padding(EdgeInsets(top: 0, leading: 35, bottom: 0, trailing: 0))
                                    .scrollIndicators(.hidden)
                                }
                                
                                Button(action: {toggleCompleteHabit(at: index)}){
                                    Image("Completebutton")
                                        .resizable()
                                        .frame(width: 28, height: 30)
                                }
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 278))
                                .disabled(editIndex == index)
                                .buttonStyle(.plain)
                                
                                Button(action: {deleteHabit(at: index)}){
                                    Image("Deletebutton")
                                        .resizable()
                                        .frame(width: 28, height: 30)
                                }
                                .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 228))
                                .disabled(editIndex == index || habits[index].1)
                                .buttonStyle(.plain)
                                
                            } //move this
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .background(Color.clear)
                        }
                        .onMove(perform: moveItem)
                        
                        Button(action: {addNewHabit()}){
                            Image("Addtask")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .buttonStyle(.plain)
                        
                        
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .toolbar {
                       EditButton() // Button to enable drag-and-drop functionality
                    }
                )
                .padding(EdgeInsets(top: 280, leading: 0, bottom: 0, trailing: 0))
            
            // Streak
            Image("Streakfire")
                .overlay(
                    Text("\(Streak)")
                        .fontDesign(.rounded)
                        .foregroundColor(.accentColor3)
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 15)
                        .opacity(Streak > 1 ? 1 : 0)
                )
                .padding(EdgeInsets(top: 0, leading: 350, bottom: 210, trailing: 0))
                .opacity(Streak > 1 ? 1 : 0)
                
            
            
            
                
        } // --Main ZStack
        .onAppear(perform: loadHabits)
    } // --View
    
    // Functions
    private func moveItem(from source: IndexSet, to destination: Int) {
        habits.move(fromOffsets: source, toOffset: destination)
        saveHabits()
    }

    
    private func addNewHabit() {
        if habits.isEmpty || !habits[habits.count - 1].0.isEmpty {
            habits.append(("", false))
        }
        editIndex = habits.count > 1 ? habits.count - 1 : 0
        saveHabits()
    }
    
    private func deleteHabit(at index: Int){
        habits.remove(at: index)
        saveHabits()
    }
    
    private func toggleCompleteHabit(at index: Int){
        habits[index].1.toggle()
        let daysDifference = Calendar.current.dateComponents([.day], from: lastStreakDate ?? currentDate, to: currentDate).day ?? 0
        
        if daysDifference == 1 {
            Streak += 1
        } else if daysDifference > 0 {
            Streak = 1
        }
                    
        lastStreakDate = currentDate
        saveHabits()
    }
    
    private func saveHabits() {
        let habitsDict = habits.map {
            habit in ["habit" : habit.0, "isCompleted" : habit.1]
        }
        UserDefaults.standard.set(habitsDict, forKey: "habits")
        UserDefaults.standard.set(Streak, forKey: "streak")
        UserDefaults.standard.set(lastStreakDate, forKey: "lastStreakDate")
    }
    
    private func loadHabits() {
        if let habitsDict = UserDefaults.standard.array(forKey: "habits") as? [[String: Any]]{
            habits = habitsDict.compactMap { dict in
                if let habit = dict["habit"] as? String,
                   let isCompleted = dict["isCompleted"] as? Bool {
                    return (habit, isCompleted)
                } else {
                    return nil
                }
            }
        } else {
            habits = []
        }
        
        Streak = UserDefaults.standard.integer(forKey: "streak") // defaults to 0 if no data
        if let savedDate = UserDefaults.standard.object(forKey: "lastStreakDate") as? Date {
            lastStreakDate = savedDate
        }
        
    }
}

#Preview {
    ContentView()
}
