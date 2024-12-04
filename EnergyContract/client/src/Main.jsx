import { useState } from "react";
import { useEth } from "./contexts/EthContext";
import "./styles.css";

function Main() {
  const {
    state: { contract, accounts },
  } = useEth();

  const [entityData, setEntityData] = useState({
    name: "",
    capacity: "",
    costPerUnit: "",
    providerAddress: "",
  });
  const [energyTransfer, setEnergyTransfer] = useState({
    to: "",
    energy: "",
  });
  const [energyConsumption, setEnergyConsumption] = useState({
    energy: "",
  });
  const [transactionKey, setTransactionKey] = useState("");
  const [transactionHistory, setTransactionHistory] = useState(null);

  const handleAddProducer = async () => {
    try {
      const { name, capacity, costPerUnit } = entityData;
      await contract.methods.addProducer(name, capacity, costPerUnit).send({ from: accounts[0] });
      alert("Producer added successfully!");
    } catch (error) {
      console.error("Error adding producer:", error);
    }
  };

  const handleAddProvider = async () => {
    try {
      const { name, capacity, costPerUnit } = entityData;
      await contract.methods.addProvider(name, capacity, costPerUnit).send({ from: accounts[0] });
      alert("Provider added successfully!");
    } catch (error) {
      console.error("Error adding provider:", error);
    }
  };

  const handleAddConsumer = async () => {
    try {
      const { name, capacity, providerAddress } = entityData;
      await contract.methods.addConsumer(name, capacity, providerAddress).send({ from: accounts[0] });
      alert("Consumer added successfully!");
    } catch (error) {
      console.error("Error adding consumer:", error);
    }
  };

  const handleTransferEnergy = async () => {
    try {
      const { to, energy } = energyTransfer;
      const key = await contract.methods.transferEnergy(to, energy).send({ from: accounts[0] });
      alert(`Energy transferred successfully! Transaction Key: ${key}`);
    } catch (error) {
      console.error("Error transferring energy:", error);
    }
  };

  const handleConsumeEnergy = async () => {
    try {
      const { energy } = energyConsumption;
      await contract.methods.ConsumeEnergy(energy).send({ from: accounts[0] });
      alert("Energy consumed successfully!");
    } catch (error) {
      console.error("Error consuming energy:", error);
    }
  };

  const fetchTransactionHistory = async () => {
    try {
      const history = await contract.methods.getTransactionHistoryByKey(transactionKey).call();
      setTransactionHistory(history);
    } catch (error) {
      console.error("Error fetching transaction history:", error);
    }
  };

  return (
    <div id="App">
      <div className="container">
        <header>
          <h1>
            <span className="grid-icon">⚡</span> Energy DApp
          </h1>
        </header>

        {/* Add Entity Section */}
        <section className="card">
          <h2>Add Entity</h2>
          <div className="form-grid">
            <input
              placeholder="Name"
              onChange={(e) => setEntityData({ ...entityData, name: e.target.value })}
            />
            <input
              placeholder="Capacity"
              onChange={(e) => setEntityData({ ...entityData, capacity: e.target.value })}
            />
            <input
              placeholder="Cost Per Unit"
              onChange={(e) => setEntityData({ ...entityData, costPerUnit: e.target.value })}
            />
            <input
              placeholder="Provider Address (Consumer)"
              onChange={(e) => setEntityData({ ...entityData, providerAddress: e.target.value })}
            />
          </div>
          <div className="button-group">
            <button onClick={handleAddProducer}>Add Producer</button>
            <button onClick={handleAddProvider}>Add Provider</button>
            <button onClick={handleAddConsumer}>Add Consumer</button>
          </div>
        </section>

        {/* Transfer Energy Section */}
        <section className="card">
          <h2>Transfer Energy</h2>
          <div className="form-grid">
            <input
              placeholder="To Address"
              onChange={(e) => setEnergyTransfer({ ...energyTransfer, to: e.target.value })}
            />
            <input
              placeholder="Energy Amount"
              onChange={(e) => setEnergyTransfer({ ...energyTransfer, energy: e.target.value })}
            />
          </div>
          <button onClick={handleTransferEnergy}>Transfer Energy</button>
        </section>

        {/* Consume Energy Section */}
        <section className="card">
          <h2>Consume Energy</h2>
          <input
            placeholder="Energy Amount"
            onChange={(e) => setEnergyConsumption({ ...energyConsumption, energy: e.target.value })}
          />
          <button onClick={handleConsumeEnergy}>Consume Energy</button>
        </section>

        {/* Fetch Transaction History */}
        <section className="card">
          <h2>Fetch Transaction History</h2>
          <input
            placeholder="Transaction Key"
            onChange={(e) => setTransactionKey(e.target.value)}
          />
          <button onClick={fetchTransactionHistory}>Fetch History</button>
          {transactionHistory && (
            <div className="transaction-details">
              <h3>Transaction Details:</h3>
              <p>Sender: {transactionHistory[0]}</p>
              <p>Sender Name: {transactionHistory[1]}</p>
              <p>Receiver: {transactionHistory[2]}</p>
              <p>Receiver Name: {transactionHistory[3]}</p>
              <p>Energy: {transactionHistory[4]}</p>
              <p>Money Sent: {transactionHistory[5]}</p>
              <p>Timestamp: {transactionHistory[6]}</p>
            </div>
          )}
        </section>
      </div>
    </div>
  );
}

export default Main;
