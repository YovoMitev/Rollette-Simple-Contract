import { ethers } from "ethers";
import fs from "fs";
import dotenv from "dotenv";
dotenv.config();
const { BLOCKCHAIN_URL, WALLET_PRIVATE_KET } = process.env;

const main = async () => {
  const provider = new ethers.providers.JsonRpcProvider(BLOCKCHAIN_URL);
  const wallet = new ethers.Wallet(WALLET_PRIVATE_KET, provider);
  const abi = fs.readFileSync(
    "./compiled/contracts_Rollette_sol_Rollette.abi",
    "utf-8"
  );
  const binary = fs.readFileSync(
    "./compiled/contracts_Rollette_sol_Rollette.bin",
    "utf-8"
  );

  const contractFactory = new ethers.ContractFactory(abi, binary, wallet);
  console.log("Deploying...");
  const contract = await contractFactory.deploy();
  //   Specify a number of confirmations that we want to acrually wait.
  const transactionReceipt = await contract.deployTransaction.wait(1);
  console.info("Contract is deployed 🚀🚀🚀 ");
  console.info("transactionReceipt", transactionReceipt);
  console.log("Contract address", contract.address);

  const balance = await contract.getContractBalance();
  const commission = await contract.getContractCommission();
  console.log("Balance: ", balance.toString());
  console.log("Commission: ", commission.toString());

  return "EtherJS Rocks!";
};

main()
  .then((data) => console.log(data))
  .catch((err) => console.error(err));
