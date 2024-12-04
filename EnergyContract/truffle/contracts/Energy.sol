// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface ERC20 {
    /**
     * @dev Transfers energy tokens from the caller to the specified address.
     * @param to The address to transfer tokens to.
     * @param tokens The number of tokens to transfer.
     * @return A uint256 value indicating the transaction result (e.g., success or a transaction ID).
     */
    function transferEnergy(address to, uint256 tokens) external returns (uint256);

    /**
     * @dev Emitted when `tokens` are transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 tokens);
}
contract Energy  is ERC20{
    uint private key;
    uint private Hid;

     event TransferOfMoney(address indexed from, address indexed to, uint256 money);
   
     bool public urgency = false;

 

    struct EnergyProductionOfProducer {
        uint256[] energy;
        uint256[] timestamp;
    }

    struct History {
        address Energysender;
        address Energyreceiver;
        uint256 Energy;
        uint256 Moneysent;
        uint256 Timestamp;
    }

    struct EnergyProduced {
        address Producer;
        string name;
        uint256 Energy;
        uint256 Timestamp;
    }

    struct EnergyConsumed {
        address Consumer;
        string name;
        uint256 Energy;
        uint256 Timestamp;
    }

    struct TABS {
        uint256[] energy;
        uint256[] timestamp;
    }
    
    struct Producer {
        string producerName;
        uint256 ProductionCapacity;
        uint256 costPerUnit;   
        TABS tab;
    }
    
    struct Provider {
        string providerName;
        uint256 StorageCapacity;
        uint256 costPerUnit;
    }
    
    struct Consumer {
        string consumerName;
        uint256 StorageCapacity;
        address provide;
        TABS tab;
    }

    // State variables
    mapping(address => uint256) public balanceOfEnergy;
    mapping(uint256 => uint256) private ReceiverTransactionId;
    mapping(address => uint8) public Entities; // 1 = Producer, 2 = Provider, 3 = Consumer
    mapping(address => Producer) public producer;
    mapping(address => Provider) public provider;
    mapping(address => Consumer) public consumer;
    mapping(address => uint256) private balancesOfMoney;
    mapping(address => uint256) private costPerUnit; 
   // mapping(address => uint256) private Entities;

    EnergyProduced[] public energyproduced;
    EnergyConsumed[] public energyconsumed;
    History[] public history;

     // Modifier to ensure the address is not already an entity
    modifier CheckIfAlreadyEntity(address _addr) {
        require(Entities[_addr] == 0, "Address is already registered as an entity");
        _;
    }

    // Function to add a producer entity
    function addProducer(
        string memory _name, 
        uint256 _productionCapacity, 
        uint256 _cpu
    ) 
        public 
        CheckIfAlreadyEntity(msg.sender) 
    {
        TABS memory tabb;
        producer[msg.sender] = Producer(_name, _productionCapacity, _cpu, tabb);
        Entities[msg.sender] = 1; // Mark as producer
    }

    function addProvider(
        string memory _name, 
        uint256 _storageCapacity, 
        uint256 _cpu
    ) 
        public 
        CheckIfAlreadyEntity(msg.sender) 
    {
        provider[msg.sender] = Provider(_name, _storageCapacity, _cpu);
        Entities[msg.sender] = 2; // Mark as provider
    }

    function addConsumer(
        string memory _name, 
        uint256 _storageCapacity, 
        address _provider
    ) 
        public 
        CheckIfAlreadyEntity(msg.sender) 
    {
        TABS memory tabb;
        consumer[msg.sender] = Consumer(_name, _storageCapacity, _provider, tabb);
        Entities[msg.sender] = 3; // Mark as consumer
    }

     // Internal function to add money to an account
    function addMoney(address accountOwner, uint256 money) public returns(uint256) {
        balancesOfMoney[accountOwner] += money;
        return money;
    }
    
    // Public function to check the balance of an account
    function balanceOfAccount(address accountOwner) 
        public 
        view 
        returns (uint256 balance) 
    {
        return balancesOfMoney[accountOwner];
    }
    
    // Public function to set the cost per unit (CPU)
    function setCostPerUnit(uint256 cpu) public {
        if (Entities[msg.sender] == 1) {
            producer[msg.sender].costPerUnit = cpu; 
        } else if (Entities[msg.sender] == 2) {
            provider[msg.sender].costPerUnit = cpu; 
        } else if (Entities[msg.sender] == 3) {
            costPerUnit[msg.sender] = cpu;  
        }
    }
    
    // Internal function to dynamically set CPU
    function SetCostPerUnit() internal view returns (uint256) {
        uint256 cpu;
        if (Entities[msg.sender] == 1) {
            cpu = producer[msg.sender].costPerUnit; 
        } else if (Entities[msg.sender] == 2) {
            cpu = provider[msg.sender].costPerUnit; 
        } else if (Entities[msg.sender] == 3) {
            if (urgency) {
                cpu = 20; // Higher rate in urgency
            } else {
                cpu = 17;  
            }
        }
        return cpu; 
    }

    // Internal function to transfer money for energy
    function TransferMoneyForEnergy(
        address from,
        address to, 
        uint256 energy
    ) 
        internal 
        returns (bool success, uint256 funds) 
    {
        uint256 CostPerUnit = SetCostPerUnit();
        uint256 money = energy * CostPerUnit;
        require(balancesOfMoney[from] >= money, "Insufficient funds to transfer");
        balancesOfMoney[from] -= money;
        balancesOfMoney[to] += money;
        emit TransferOfMoney(from, to, money);
        return (true, money);
    }
    // Add energy created by a producer
    function addCreatedEnergy(uint256 energy) public {
        //require(Entities[msg.sender] == 1, "Not a producer");
        require(energy <= producer[msg.sender].ProductionCapacity, "Exceeds production capacity");

        balanceOfEnergy[msg.sender] += energy;
        energyproduced.push(EnergyProduced(msg.sender, producer[msg.sender].producerName, energy, block.timestamp));
        producer[msg.sender].tab.energy.push(energy);
        producer[msg.sender].tab.timestamp.push(block.timestamp);
    }

    // Get energy production details for an address
    function getProductionOfAddress(address _producer) public view returns (uint256[] memory, uint256[] memory) {
        return (producer[_producer].tab.energy, producer[_producer].tab.timestamp);
    }

    // Get energy consumption details for an address
    function getConsumptionOfAddress(address _consumer) public view returns (uint256[] memory, uint256[] memory) {
        return (consumer[_consumer].tab.energy, consumer[_consumer].tab.timestamp);
    }

    // Store transfer details
    function StoreTransferDetails(address _from, address _to, uint256 _energy, uint256 _funds) private {
        Hid = history.length;
        history.push(History(_from, _to, _energy, _funds, block.timestamp));
    }

    // Get balance of energy for a specific address
    function BalanceOfEnergy(address energyOwner) public view returns (uint256) {
        return balanceOfEnergy[energyOwner];
    }

  // Function to transfer energy
    function transferEnergy(address _to, uint256 energy) public returns (uint256) {
        if (Entities[_to] == 2) {
            // Provider
            require(balanceOfEnergy[msg.sender] >= energy, "Insufficient energy balance");
            require(balanceOfEnergy[_to] + energy <= provider[_to].StorageCapacity, "Exceeds provider capacity");
        } else if (Entities[_to] == 3) {
            // Consumer
            if (Entities[msg.sender] == 2) {
                // If sender is a provider
                require(balanceOfEnergy[msg.sender] >= energy, "Insufficient energy balance");
            }
            require(balanceOfEnergy[_to] + energy <= consumer[_to].StorageCapacity, "Exceeds consumer capacity");
            if (urgency) {
                address providerAddress = consumer[msg.sender].provide;
                require(providerAddress != address(0), "Invalid provider address");

                balanceOfEnergy[providerAddress] -= energy;
                balanceOfEnergy[msg.sender] += energy;

                (, uint256 fundds) = TransferMoneyForEnergy(msg.sender, providerAddress, energy);
                StoreTransferDetails(msg.sender, providerAddress, energy, fundds);

                key = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, energy, fundds))) % (10**16);
                ReceiverTransactionId[key] = Hid;
                return key;
                }
                }
                  // General transfer logic
        balanceOfEnergy[msg.sender] -= energy;
        balanceOfEnergy[_to] += energy;

        (, uint256 funds) = TransferMoneyForEnergy(_to, msg.sender, energy);
        emit Transfer(msg.sender, _to, energy);

        StoreTransferDetails(msg.sender, _to, energy, funds);

        key = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, energy, funds))) % (10**16);
        ReceiverTransactionId[key] = Hid;

        return key;
        }


        


    // Consume energy for a consumer
    function ConsumeEnergy(uint256 _energy) public {
        require(Entities[msg.sender] == 3, "Not a consumer");

        if (balanceOfEnergy[msg.sender] < _energy) {
            uint256 temp = _energy - balanceOfEnergy[msg.sender];
            balanceOfEnergy[msg.sender] = 0;
            urgency = true;
            transferEnergy(msg.sender, consumer[msg.sender].StorageCapacity);
            balanceOfEnergy[msg.sender] -= temp;
        } else {
            balanceOfEnergy[msg.sender] -= _energy;
        }

        energyconsumed.push(EnergyConsumed(msg.sender, consumer[msg.sender].consumerName, _energy, block.timestamp));
        consumer[msg.sender].tab.energy.push(_energy);
        consumer[msg.sender].tab.timestamp.push(block.timestamp);
        urgency = false;
    }

    // Get transaction history by key
    function getTransactionHistoryByKey(uint256 _key)
        public
        view
        returns (
            address,
            string memory,
            address,
            string memory,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 index = ReceiverTransactionId[_key];
        string memory senderName;
        string memory receiverName;

        if (Entities[history[index].Energysender] == 1) {
            senderName = producer[history[index].Energysender].producerName;
        } else if (Entities[history[index].Energysender] == 2) {
            senderName = provider[history[index].Energysender].providerName;
        } else {
            senderName = consumer[history[index].Energysender].consumerName;
        }

        if (Entities[history[index].Energyreceiver] == 1) {
            receiverName = producer[history[index].Energyreceiver].producerName;
        } else if (Entities[history[index].Energyreceiver] == 2) {
            receiverName = provider[history[index].Energyreceiver].providerName;
        } else {
            receiverName = consumer[history[index].Energyreceiver].consumerName;
        }

        return (
            history[index].Energysender,
            senderName,
            history[index].Energyreceiver,
            receiverName,
            history[index].Energy,
            history[index].Moneysent,
            block.timestamp
        );
}
    

    
}
