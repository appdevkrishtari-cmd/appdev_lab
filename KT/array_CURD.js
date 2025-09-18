type User = {
  id: number;
  name: string;
};

class UserManager {
  private users: User[] = [];

  // Create
  addUser(name: string): User {
    const newUser: User = {
      id: Date.now(), // simple unique ID
      name
    };
    this.users.push(newUser);
    return newUser;
  }

  // Read
  getUsers(): User[] {
    return this.users;
  }

  getUserById(id: number): User | undefined {
    return this.users.find(user => user.id === id);
  }

  // Update
  updateUser(id: number, newName: string): boolean {
    const user = this.getUserById(id);
    if (user) {
      user.name = newName;
      return true;
    }
    return false;
  }

  // Delete
  deleteUser(id: number): boolean {
    const index = this.users.findIndex(user => user.id === id);
    if (index !== -1) {
      this.users.splice(index, 1);
      return true;
    }
    return false;
  }
}

// ------------------------
// 🔍 Example Usage
// ------------------------

const manager = new UserManager();

const user1 = manager.addUser("Alice");
const user2 = manager.addUser("Bob");

console.log("All Users:", manager.getUsers());

manager.updateUser(user1.id, "Alice Updated");

console.log("After Update:", manager.getUsers());

manager.deleteUser(user2.id);

console.log("After Deletion:", manager.getUsers());
