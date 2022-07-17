const fs = require("fs-extra"); //to read the abi
const ethers = require("ethers");
//import dotenv
require("dotenv").config();

async function main() {
  //first thing is to compile the code with solc.js
  //compile them separetely
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
  //for environment variables yarn add dotenv
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY_OWNER, provider);
  //private key that we should not show

  //CREATED THE ABI AND THE BINARY WITH THE FOLLOWING: yarn solcjs --bin --abi --include-path node_modules/ --base-path . -o . vWorld.sol but automates in package.json(scripts)
  const abi = fs.readFileSync("./vWorld_sol_vWorld.abi", "utf8"); //utf8 is the encoding
  const binary = fs.readFileSync("./vWorld_sol_vWorld.bin", "utf8");
  const contractFactory = new ethers.ContractFactory(abi, binary, wallet);
  console.log("Deploying please wait");
  const contract = await contractFactory.deploy(); //so we have to wait for the contract factory to be deployed
  const deploymentReceipt = await contract.deployTransaction.wait(1);
  console.log(deploymentReceipt);

  //INTERACT WITH THE CONTRACT
  const createArea1 = await contract.createArea(
    "0xc8e96ac5529fe3d80f8cc3dea3b1e0a6b2329e17",
    "(x1,y1)",
    "100000000",
    0,
    true
  );
  const updateArea1 = await createArea1.wait(1);
  //The second are will also cost the same as the first one, just at the beginning because they have the same size
  const createArea2 = await contract.createArea(
    "0xc8e96ac5529fe3d80f8cc3dea3b1e0a6b2329e17",
    "(x2,y2)",
    "100000000",
    1,
    true
  );
  const updateArea2 = await createArea2.wait(1);
  //The third area will cost the double because it is almost as twice as bigger
  const createArea3 = await contract.createArea(
    "0xc8e96ac5529fe3d80f8cc3dea3b1e0a6b2329e17",
    "(x3,y3)",
    "200000000",
    2,
    true
  );
  const updateArea3 = await createArea3.wait(1);

  console.log(
    `Your areas have been created${(updateArea1, updateArea2, updateArea3)}`
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
