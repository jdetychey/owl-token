pragma solidity ^0.4.21;

import "@gnosis.pm/util-contracts/contracts/Math.sol";
import "@gnosis.pm/util-contracts/contracts/StandardToken.sol";
import "@gnosis.pm/util-contracts/contracts/Proxy.sol";

contract TokenOWL is Proxied, StandardToken {
    using Math for *;

    string public constant name = "OWL Token";
    string public constant symbol = "OWL";
    uint8 public constant decimals = 18;

    struct masterCopyCountdownType {
        address masterCopy;
        uint timeWhenAvailable;
    }

    masterCopyCountdownType masterCopyCountdown;

    address public creator;
    address public minter;

    event Minted(address indexed to, uint256 amount);
    event Burnt(address indexed from, address indexed user, uint256 amount);

    modifier onlyCreator() {
        // R1
        require(msg.sender == creator);
        _;
    }
    /// @dev trickers the update process via the proxyMaster for a new address _masterCopy 
    /// updating is only possible after 30 days
    function startMasterCopyCountdown (
        address _masterCopy
     )
        public
        onlyCreator()
    {
        require(address(_masterCopy) != 0);

        // Update masterCopyCountdown
        masterCopyCountdown.masterCopy = _masterCopy;
        masterCopyCountdown.timeWhenAvailable = now + 30 days;
    }

     /// @dev executes the update process via the proxyMaster for a new address _masterCopy
    function updateMasterCopy()
        public
        onlyCreator()
    {   
        require(address(masterCopyCountdown.masterCopy) != 0);
        require(now >= masterCopyCountdown.timeWhenAvailable);

        // Update masterCopy
        masterCopy = masterCopyCountdown.masterCopy;
    }

    function getMasterCopy()
        public
        view
        returns (address)
    {
        return masterCopy;
    }

    /// @dev Set minter. Only the creator of this contract can call this.
    /// @param newMinter The new address authorized to mint this token
    function setMinter(address newMinter)
        public
        onlyCreator()
    {
        minter = newMinter;
    }


    /// @dev change owner/creator of the contract. Only the creator/owner of this contract can call this.
    /// @param newOwner The new address, which should become the owner
    function setNewOwner(address newOwner)
        public
        onlyCreator()
    {
        creator = newOwner;
    }

    /// @dev Mints OWL.
    /// @param to Address to which the minted token will be given
    /// @param amount Amount of OWL to be minted
    function mintOWL(address to, uint amount)
        public
    {
        require(minter != 0 && msg.sender == minter);
        balances[to] = balances[to].add(amount);
        totalTokens = totalTokens.add(amount);
        emit Minted(to, amount);
    }

    /// @dev Burns OWL.
    /// @param user Address of OWL owner
    /// @param amount Amount of OWL to be burnt
    function burnOWL(address user, uint amount)
        public
    {
        allowances[user][msg.sender] = allowances[user][msg.sender].sub(amount);
        balances[user] = balances[user].sub(amount);
        totalTokens = totalTokens.sub(amount);
        emit Burnt(msg.sender, user, amount);
    }
}
