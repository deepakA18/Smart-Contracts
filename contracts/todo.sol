//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

contract Todos{
    struct Todo{
        string text;
        bool completed;      
    }

    Todo [] public todos;

    function create(string memory _text) public{
        //3 ways to initialise struct:

        todos.push(Todo(_text,false));

        //key-value mapping:
        todos.push(Todo({text: _text, completed: false}));

        //initialise empty and then update:
        Todo memory todo;
        todo.text = _text;
        todo.completed = false;

        todos.push(todo);
    }

    function get(uint256 _index) public view returns(string memory text, bool completed){

        Todo storage todo = todos[_index];
        return (todo.text, todo.completed);
}

    function updateStatus(string memory _text, uint256 _index) public {
        Todo storage todo = todos[_index];
        todo.text = _text;
    }

    function toggleStatus(uint256 _index) public {
        Todo storage todo = todos[_index];
        todo.completed = !todo.completed;
    }

    

}