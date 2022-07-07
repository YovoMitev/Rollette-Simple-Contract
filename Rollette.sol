// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

error NotOwner();

contract Rollette {
    address public immutable i_owner;
    address[] public participants;
    // addresses and the amount of EHT for the participants.
    mapping(address => uint256) public participantsAddressToAmount;
    // const variable is more cheeper to read
    uint public constant DEPOSITION_ETHERS = 0.01 * 10**18; // 1 * 10 ** 18

    constructor() {
        i_owner = msg.sender;
    }

    function addFunds() public payable {
        require(
            msg.value == DEPOSITION_ETHERS,
            "Invalid deposit, please send 0.01 ETH!"
        );

        participantsAddressToAmount[msg.sender] = msg.value;
        participants.push(msg.sender);
    }

    // use  block.difficulty, block.timestamp for experemenint purpose, I know the best practise is to use an oracle.
    function chooseAWinner() public view returns (uint) {
        uint randomNumber = uint(
            keccak256(
                abi.encodePacked(
                    block.difficulty,
                    block.timestamp,
                    participants
                )
            )
        );

        return randomNumber & participants.length;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 participantIndex = 0;
            participantIndex < participants.length;
            participantIndex++
        ) {
            address participant = participants[participantIndex];
            participantsAddressToAmount[participant] = 0;
        }
        // reset array
        participants = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed!");
    }

    function getParticipants() public view returns (uint256) {
        return participants.length;
    }

    function spin() public onlyOwner {}

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }
}
