import SwiftUI

// Task model, conforms to Codable for UserDefaults persistence
struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
}

struct ContentView: View {
    @State private var tasks: [Task] = UserDefaults.standard.tasks(forKey: "tasks") { // Persist tasks using UserDefaults
        didSet {
            UserDefaults.standard.set(tasks, forKey: "tasks")
        }
    }
    @State private var newTaskTitle = ""         // For storing new task input
    @FocusState private var isTextFieldFocused: Bool  // Control keyboard focus state

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(tasks) { task in
                        Text(task.title)       // Display each task
                    }
                    .onDelete(perform: deleteTask)  // Swipe to delete functionality
                }
                .navigationTitle("To-Do List")     // Navigation bar title
                
                HStack {
                    TextField("New Task", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .focused($isTextFieldFocused)  // Control focus for the keyboard
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isTextFieldFocused = true  // Automatically focus TextField on view appear
                            }
                        }

                    Button(action: addTask) {
                        Image(systemName: "plus")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .padding()
                }
                .padding()
            }
        }
    }

    // Add a new task to the list
    func addTask() {
        if !newTaskTitle.isEmpty {
            let task = Task(title: newTaskTitle)
            tasks.append(task)
            newTaskTitle = ""         // Clear the text field after adding the task
        }
    }

    // Delete a task from the list
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

// UserDefaults extension to save and load tasks from the device storage
extension UserDefaults {
    func tasks(forKey key: String) -> [Task] {
        if let data = data(forKey: key), let savedTasks = try? JSONDecoder().decode([Task].self, from: data) {
            return savedTasks
        }
        return []
    }

    func set(_ tasks: [Task], forKey key: String) {
        if let data = try? JSONEncoder().encode(tasks) {
            set(data, forKey: key)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
