const rollInput = document.getElementById('roll-input');
const nameInput = document.getElementById('name-input');
const addBtn = document.getElementById('add-btn');
const studentList = document.getElementById('student-list');

let students = JSON.parse(localStorage.getItem('students')) || [];

// CREATE
addBtn.addEventListener('click', () => {
  const roll = rollInput.value.trim();
  const name = nameInput.value.trim();

  if (roll && name) {
    // Check duplicate roll number
    if (students.some(student => student.roll === roll)) {
      alert("Roll number already exists!");
      return;
    }

    const newStudent = { id: Date.now(), roll, name };
    students.push(newStudent);

    rollInput.value = '';
    nameInput.value = '';

    renderStudents();
    saveStudents();
  } else {
    alert("Please enter both Roll Number and Name");
  }
});

// READ (render)
function renderStudents() {
  studentList.innerHTML = '';
  students.forEach(student => {
    const row = document.createElement('tr');
    row.innerHTML = `
      <td>${student.roll}</td>
      <td>${student.name}</td>
      <td>
        <button onclick="editStudent(${student.id})">Edit</button>
        <button onclick="deleteStudent(${student.id})">Delete</button>
      </td>
    `;
    studentList.appendChild(row);
  });
}

// UPDATE
window.editStudent = function(id) {
  const student = students.find(s => s.id === id);
  if (!student) return;

  const newRoll = prompt("Edit Roll Number:", student.roll);
  const newName = prompt("Edit Name:", student.name);

  if (newRoll && newName) {
    // Ensure unique roll numbers
    if (students.some(s => s.roll === newRoll && s.id !== id)) {
      alert("Roll number already exists!");
      return;
    }

    students = students.map(s =>
      s.id === id ? { ...s, roll: newRoll, name: newName } : s
    );
    renderStudents();
    saveStudents();
  }
};

// DELETE
window.deleteStudent = function(id) {
  students = students.filter(s => s.id !== id);
  renderStudents();
  saveStudents();
};

// Save to localStorage
function saveStudents() {
  localStorage.setItem('students', JSON.stringify(students));
}

// Initial render
renderStudents();
