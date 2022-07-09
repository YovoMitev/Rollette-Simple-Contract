// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

error NotOwner();
error CampaingStarted();

contract Rollette {
    uint public rolletteRounds;
    address public immutable i_owner;
    address[] public participants;
    // addresses and the amount of EHT for the participants.
    mapping(address => uint256) public participantsAddressToAmount;
    // The deposit is exact 0.01 eth.
    uint public constant DEPOSITION_ETHERS = 0.01 * 10**18;
    // After each spin, the contract gets 5% commission.
    uint public constant COMMISSION_PERCENTAGE = 5;

    constructor() {
        i_owner = msg.sender;
    }

    function getThePrize() public view returns (uint256) {
        return getCurrentLockedBalance() - getContractCommission();
    }

    function getContractCommission() public view returns (uint256) {
        return (getCurrentLockedBalance() * COMMISSION_PERCENTAGE) / 100;
    }

    function getCurrentLockedBalance() public view returns (uint) {
        uint total;
        for (
            uint256 participantIndex = 0;
            participantIndex < participants.length;
            participantIndex++
        ) {
            address participant = participants[participantIndex];
            total += participantsAddressToAmount[participant];
        }

        return total;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getParticipantBalance() public view returns (uint256) {
        return participantsAddressToAmount[msg.sender];
    }

    function addFunds() public payable {
        require(
            msg.value == DEPOSITION_ETHERS,
            "Invalid deposit, please send 0.01 ETH!"
        );
        // One participant can deposit only one time for rolletter round.
        require(
            participantsAddressToAmount[msg.sender] == 0,
            "You already added a funds!"
        );

        participantsAddressToAmount[msg.sender] = msg.value;
        participants.push(msg.sender);
    }

    // use  block.difficulty, block.timestamp instead of oracle, because of simplify
    function chooseWinner() internal view returns (uint) {
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

    function withdraw() public onlyOwner withdrawOnFinishedCampaign {
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Withdraw failed!");
    }

    function getParticipants() public view returns (uint256) {
        return participants.length;
    }

    function spin() public onlyOwner {
        uint winnerIndex = chooseWinner();
        address winnerAddress = participants[winnerIndex];

        (bool callSuccess, ) = payable(winnerAddress).call{
            value: getThePrize()
        }("");
        require(callSuccess, "Withdraw failed!");

        // Rest participants funds
        for (
            uint256 participantIndex = 0;
            participantIndex < participants.length;
            participantIndex++
        ) {
            address participantAddress = participants[participantIndex];
            participantsAddressToAmount[participantAddress] = 0;
        }
        // reset participants array
        participants = new address[](0);

        rolletteRounds++;
    }

    receive() external payable {
        addFunds();
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    modifier withdrawOnFinishedCampaign() {
        if (participants.length > 0) {
            revert CampaingStarted();
        }
        _;
    }
}
