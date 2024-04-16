//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

contract Events {
    //Upto 3 indexed parameters
    //Indexed parameter helps you fill the logs by the indexed parameter

    event Log(address indexed sender, string message);
    event AnotherLog();

    function test() public {
        emit Log(msg.sender, "Hey Receiver!");
        emit AnotherLog();
    }
}
