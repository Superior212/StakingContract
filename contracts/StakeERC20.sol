// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract StakeERC20 is ReentrancyGuard {
    IERC20 public stakingToken;
    address public owner;

    uint256 public constant MIN_DURATION = 1 minutes; // Minimum duration for staking
    uint256 public constant MAX_DURATION = 60 days; // Maximum duration for staking
    uint256 public constant DAYS_IN_YEAR = 365;
    uint256 public constant FIXED_RATE = 10; // Annual fixed interest rate in percentage

    struct Stake {
        address staker;
        uint256 amount;
        uint256 endTime;
        uint256 expectedReward;
        bool isComplete;
    }

    mapping(address => Stake[]) public userStakes;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    event Staked(address indexed user, uint256 amount, uint256 duration);
    event RewardClaimed(address indexed user, uint256 amount);
    event Withdrawal(address indexed owner, uint256 amount);

    constructor(IERC20 _stakingToken) {
        stakingToken = _stakingToken;
        owner = msg.sender;
    }

    // Function to stake STK tokens into the contract
    function stake(
        uint256 amount,
        uint256 durationInSeconds
    ) external nonReentrant {
        require(amount > 0, "Stake amount must be greater than zero.");
        require(
            durationInSeconds >= MIN_DURATION &&
                durationInSeconds <= MAX_DURATION,
            "Duration must be between the allowed range."
        );

        // Transfer the staking tokens from the user to the contract
        stakingToken.transferFrom(msg.sender, address(this), amount);

        // Calculate the expected reward based on the amount, rate, and duration
        uint256 expectedReward = calculateReward(
            amount,
            FIXED_RATE,
            durationInSeconds
        );

        // Create a new stake
        Stake memory newStake = Stake({
            staker: msg.sender,
            amount: amount,
            endTime: block.timestamp + durationInSeconds,
            expectedReward: expectedReward,
            isComplete: false
        });

        // Store the new stake in the user's stakes array
        userStakes[msg.sender].push(newStake);

        // Emit an event to log the staking action
        emit Staked(msg.sender, amount, durationInSeconds);
    }

    // Function to claim the reward after the staking period has ended
    function claimReward(uint256 _index) external nonReentrant {
        require(
            _index < userStakes[msg.sender].length,
            "Invalid index: out of bounds"
        );

        // Retrieve the selected stake
        Stake storage selectedStake = userStakes[msg.sender][_index];

        // Ensure the staking period has ended
        require(
            block.timestamp >= selectedStake.endTime,
            "Stake period has not yet ended."
        );
        // Ensure the stake has not already been completed
        require(!selectedStake.isComplete, "Stake already completed.");

        // Mark the stake as complete
        selectedStake.isComplete = true;

        // Transfer the staked amount and the reward back to the user
        stakingToken.transfer(
            msg.sender,
            selectedStake.amount + selectedStake.expectedReward
        );

        // Emit an event to log the reward claim
        emit RewardClaimed(msg.sender, selectedStake.expectedReward);
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

        // Calculate the penalty (50% of the expected reward)
        uint256 penalty = selectedStake.expectedReward / 2;
        uint256 refundAmount = selectedStake.amount +
            selectedStake.expectedReward -
            penalty;

        // Mark the stake as complete
        selectedStake.isComplete = true;

        // Transfer the remaining amount after penalty back to the user
        stakingToken.transfer(msg.sender, refundAmount);
    }

    // Function to retrieve the total staked amount for a user
    function getUserTotalStaked(
        address _address
    ) external view returns (uint256 totalStaked) {
        for (uint256 i = 0; i < userStakes[_address].length; i++) {
            totalStaked += userStakes[_address][i].amount;
        }
        return totalStaked;
    }

    // Private function to calculate rewards based on simple interest formula
    function calculateReward(
        uint256 principal,
        uint256 rate,
        uint256 durationInSeconds
    ) private pure returns (uint256) {
        uint256 timeInYears = (durationInSeconds * 1e18) /
            (DAYS_IN_YEAR * 1 days); // Convert duration to years in wei for precision
        uint256 interest = (principal * rate * timeInYears) / (100 * 1e18); // Calculate interest
        return interest; // Return the reward (interest)
    }

    // Function to allow the owner to withdraw tokens from the contract
    function withdraw(uint256 amount) external onlyOwner nonReentrant {
        require(
            stakingToken.balanceOf(address(this)) >= amount,
            "Insufficient contract balance."
        );
        stakingToken.transfer(msg.sender, amount);

        // Emit an event to log the withdrawal action
        emit Withdrawal(msg.sender, amount);
    }
}
