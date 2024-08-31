// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Importing ReentrancyGuard from OpenZeppelin
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract StakeEther is ReentrancyGuard {
    // Constants
    uint256 public constant MIN_DURATION = 1 minutes; // Minimum duration for staking
    uint256 public constant MAX_DURATION = 60 days; // Maximum duration for staking
    uint256 public constant DAYS_IN_YEAR = 365;
    uint256 public constant FIXED_RATE = 10; // Annual fixed interest rate in percentage

    // Owner address
    address public owner;

    // Constructor to initialize the contract with a fund and set the owner
    constructor() payable {
        require(
            msg.value > 0,
            "Initial contract amount must be greater than zero."
        );
        owner = msg.sender; // Set the contract deployer as the owner
    }

    struct Stake {
        address _address;
        uint256 endTime;
        uint256 expectedInterest;
        bool isComplete;
    }

    mapping(address => Stake[]) userStakes;

    // Modifier to restrict function access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    event Staked(address indexed user, uint256 amount, uint256 duration);
    event RewardClaimed(address indexed user, uint256 amount);
    event Withdrawal(address indexed owner, uint256 amount);

    // Function to stake Ether into the contract
    function stake(uint256 durationInSeconds) external payable {
        require(
            msg.sender != address(0),
            "Invalid address: zero address detected."
        );
        require(msg.value > 0, "Stake amount must be greater than zero.");
        require(
            durationInSeconds >= MIN_DURATION &&
                durationInSeconds <= MAX_DURATION,
            "Duration must be between the allowed range."
        );

        // Calculate the expected interest based on the principal, rate, and duration
        uint256 expectedInterest = calculateInterest(
            msg.value,
            FIXED_RATE,
            durationInSeconds
        );

        // Create a new stake
        Stake memory newStake = Stake({
            _address: msg.sender,
            endTime: block.timestamp + durationInSeconds,
            expectedInterest: expectedInterest,
            isComplete: false
        });

        // Store the new stake in the user's stakes array
        userStakes[msg.sender].push(newStake);

        // Emit an event to log the staking action
        emit Staked(msg.sender, msg.value, durationInSeconds);
    }

    // Function to claim the reward after the staking period has ended
    function claimReward(
        address _address,
        uint256 _index
    ) external nonReentrant {
        require(
            _address != address(0),
            "Invalid address: zero address detected."
        );
        require(
            _index < userStakes[_address].length,
            "Invalid index: out of bounds."
        );

        // Retrieve the selected stake
        Stake storage selectedStake = userStakes[_address][_index];

        // Ensure the staking period has ended
        require(
            block.timestamp > selectedStake.endTime,
            "Stake period has not yet ended."
        );
        // Ensure the stake has not already been completed
        require(!selectedStake.isComplete, "Stake already completed.");
        // Ensure the contract has enough balance to pay out the reward
        require(
            address(this).balance >= selectedStake.expectedInterest,
            "Insufficient contract balance."
        );

        // Mark the stake as complete and transfer the reward to the user
        selectedStake.isComplete = true;
        (bool success, ) = _address.call{value: selectedStake.expectedInterest}(
            ""
        );
        require(success, "Reward transfer failed.");

        // Emit an event to log the reward claim
        emit RewardClaimed(_address, selectedStake.expectedInterest);
    }

    // Function to retrieve all stakes of a user
    function getAllUserStakes(
        address _address
    ) external view returns (Stake[] memory) {
        require(
            _address != address(0),
            "Invalid address: zero address detected."
        );
        require(
            userStakes[_address].length > 0,
            "No stakes found for this user."
        );

        return userStakes[_address];
    }

    // Private function to calculate interest based on simple interest formula
    function calculateInterest(
        uint256 principal,
        uint256 rate,
        uint256 durationInSeconds
    ) private pure returns (uint256) {
        uint256 timeInYears = (durationInSeconds * 1e18) /
            (DAYS_IN_YEAR * 1 days); // Convert duration to years in wei for precision
        uint256 interest = (principal * rate * timeInYears) / (100 * 1e18); // Calculate interest
        return principal + interest; // Return total amount including interest
    }

    // Function to allow early withdrawal with a penalty
    function earlyWithdraw(uint256 _index) external nonReentrant {
        require(
            _index < userStakes[msg.sender].length,
            "Invalid index: out of bounds"
        );

        // Retrieve the selected stake
        Stake storage selectedStake = userStakes[msg.sender][_index];
        // Ensure the stake has not already been completed
        require(!selectedStake.isComplete, "Stake already completed.");
        // Ensure the staking period has not ended
        require(
            block.timestamp < selectedStake.endTime,
            "Staking period has ended"
        );

        // Calculate the penalty (50% of the expected interest)
        uint256 penalty = selectedStake.expectedInterest / 2;
        uint256 refundAmount = selectedStake.expectedInterest - penalty;
        selectedStake.isComplete = true;

        // Transfer the remaining amount after penalty back to the user
        (bool success, ) = msg.sender.call{value: refundAmount}("");
        require(success, "Early withdrawal failed");
    }

    // Function to retrieve the total staked amount for a user
    function getUserTotalStaked(
        address _address
    ) external view returns (uint256 totalStaked) {
        for (uint256 i = 0; i < userStakes[_address].length; i++) {
            totalStaked += userStakes[_address][i].expectedInterest;
        }
        return totalStaked;
    }

    // Function to allow the owner to withdraw Ether from the contract
    function withdraw(uint256 amount) external onlyOwner nonReentrant {
        require(
            address(this).balance >= amount,
            "Insufficient contract balance."
        );
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed.");

        // Emit an event to log the withdrawal action
        emit Withdrawal(msg.sender, amount);
    }

    // Fallback function to receive Ether
    receive() external payable {}
}
