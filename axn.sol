pragma solidity ^0.4.17;


library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract Ownable {
    address public owner;
    
    function Ownable() public {
        owner = msg.sender;
        
    }
    
    modifier onlyOwner() {
        
        require(msg.sender == owner);
        _;
    }
    
   function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
    
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}


contract AEXONToken is Pausable {
    using SafeMath for uint256;
    
    
	string public name;
	string public symbol;
	uint8 public decimals = 18;
	uint256 public totalSupply;
	
	mapping (address => uint256) balances;
	mapping (address => bool) public frozenAccount;
	mapping (address => mapping (address => uint256)) allowed;

	
	
	event Transfer (address indexed from, address indexed to, uint256 value);
	event Burn (address indexed from, uint256 value);
	event FrozenFunds(address target, bool frozen);
	  event Approval(address indexed owner, address indexed spender, uint256 value);
	  
	/* Constructor function
	 * Initialize the parameters
	 *
	 *
	 *
	*/
	function AEXONToken(){
		totalSupply = 100000 * 10**uint256(decimals); //make sure its typecast to uint256
		balances[msg.sender]=totalSupply;
		name = 'AEXONToken';
		symbol = 'AXN99';
	}
    
    function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
    
    function _transfer(address _from, address _to, uint256 _value) internal {
        require (_to !=0x0);
        require (!frozenAccount[_from]);
        require (!frozenAccount[_to]);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances [_to].add(_value);
        Transfer(_from, _to, _value);
    }
    
    function mintToken(address target, uint256 amount) onlyOwner public {
        uint256 amount4team = amount/4;  //for every 4 tokens minted, 1 token kept for team 
        balances[target] = balances[target].add(amount);
        balances[owner] = balances[owner].add(amount4team);
        totalSupply = totalSupply.add(amount);
        totalSupply = totalSupply.add(amount4team);
    }
    

    function transfer(address target, uint256 amount) onlyOwner public {
        
        _transfer(msg.sender, target, amount);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        var _allowance = allowed[_from][msg.sender];
    
        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);
    
        balances[_to] = balances[_to].add(_value);
		
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) returns (bool) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
    
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
        
    }
    
    function freezeAccounts(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
    
    function burn(uint256 amount) public returns (bool success) {
        require(balances[msg.sender] >= amount);
        balances[msg.sender]=balances[msg.sender].sub(amount);
        totalSupply = totalSupply.add(amount);
        Burn(msg.sender, amount);
        return true;
    }
    	
}
