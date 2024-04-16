//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

contract Parent_A {
    function any() public pure virtual returns (string memory) {
        return "I am Parent A";
    }
}

contract Child_B is Parent_A {
    function any() public pure virtual override returns (string memory) {
        return "I am child of A";
    }
}

contract child_C is Parent_A, Child_B {
    function any()
        public
        pure
        override(Parent_A, Child_B)
        returns (string memory)
    {
        return super.any();
    }
}
