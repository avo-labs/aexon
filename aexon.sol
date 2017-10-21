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


contract AEXONToken is Ownable {
    using SafeMath for uint256;
    
    
	string public name;
	string public symbol;
	uint8 public decimals = 3;
	uint256 public totalSupply;
	
	mapping (address => uint256) public balanceOf;
	mapping (address => bool) public frozenAccount;
	
	
	
	event Transfer (address indexed from, address indexed to, uint256 value);
	event Burn (address indexed from, uint256 value);
	event FrozenFunds(address target, bool frozen);
	
	/* Constructor function
	 * Initialize the parameters
	 *
	 *
	 *
	*/
	function AEXONToken(){
		totalSupply = 1 * 10**uint256(decimals); //make sure its typecast to uint256
		balanceOf[msg.sender]=totalSupply;
		name = 'AEXONToken';
		symbol = 'AXN5';
	}
    
    
    function _transfer(address _from, address _to, uint256 _value) internal {
        require (_to !=0x0);
        require (!frozenAccount[_from]);
        require (!frozenAccount[_to]);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf [_to].add(_value);
        Transfer(_from, _to, _value);
    }
    
    function mintToken(address target, uint256 amount) onlyOwner public {
        uint256 amount4team = amount/4;  //for every 4 tokens minted, 1 token kept for team 
        balanceOf[target] = balanceOf[target].add(amount);
        balanceOf[owner] = balanceOf[owner].add(amount4team);
        totalSupply = totalSupply.add(amount);
        totalSupply = totalSupply.add(amount4team);
    }
    

    function transfer(address target, uint256 amount) onlyOwner public {
        
        _transfer(msg.sender, target, amount);
    }
    
    function freezeAccounts(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
    
    function burn(uint256 amount) public returns (bool success) {
        require(balanceOf[msg.sender] >= amount);
        balanceOf[msg.sender]=balanceOf[msg.sender].sub(amount);
        totalSupply = totalSupply.add(amount);
        Burn(msg.sender, amount);
        return true;
    }  
	
}
