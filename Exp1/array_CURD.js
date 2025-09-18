// Step 1: Initial array
let fruits = ["apple", "mango"];

// Step 2: Create - Add a fruit
function addFruit(fruit) {
  fruits.push(fruit);
  console.log(`${fruit} added.`);
}

// Step 3: Read - Show all fruits
function getFruits() {
  console.log("Fruits:", fruits);
}

// Step 4: Update - Change fruit by index
function updateFruit(index, newFruit) {
  if (index >= 0 && index < fruits.length) {
    console.log(`${fruits[index]} updated to ${newFruit}`);
    fruits[index] = newFruit;
  } else {
    console.log("Invalid index");
  }
}

// Step 5: Delete - Remove fruit by index
function deleteFruit(index) {
  if (index >= 0 && index < fruits.length) {
    const removed = fruits.splice(index, 1);
    console.log(`${removed[0]} removed.`);
  } else {
    console.log("Invalid index");
  }
}

// Step 6: Example usage
getFruits();               
addFruit("banana");        
getFruits();               
updateFruit(1, "orange");  
getFruits();               
deleteFruit(0);            
getFruits();               
