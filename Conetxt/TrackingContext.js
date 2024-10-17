import React, { useState, useEffect, Children} from "react";
import Web3Modal from "web3modal";
import {ethers} from "ethers";

//INTERNAL iMPORT
import tracking from "../Conetxt/Tracking.json";
const ContractAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
const ContractABI = tracking.abi;

//--Fetching SMArt contract
const fetchContract = (signedOrProvider) =>
    new ethers.Contract(ContactAddress, ContractABI, signedOrProvider);

export const TrackingProvider = ({ children }) => {
    //STATE VARIABLE
    const DappName = "Product Tracking Dapp";
    const [currentUser, setCurrentUser] = useState("");

    const createShipment = async (items) => {
        console.log(items);
        const { receiver, pickupTime, distance, price } = items;

        try {
            const web3Modal = new Web3Modal();
            const Connection = await web3Modal.connect();
            const provider = new ethers.providers.Web3Provider(Connection);
            const signer = provider.getSigner();
            const contract = fetchContract(signer);
            const createItem = await contract.createShipment (
                receiver,
                new Date(pickupTime).getTime(),
                distance,
                ethers.utils.parseUnits(price, 18),
                {
                    value: ethers.utils.parseUnits(price, 18),
                }
            );
            await createItem.wait();
            console.log(createItem);
        } catch (error) {
            console.log("Something went wrong", error);
        }
    };

    const getAllShipment = async () => {
        try{
            const provider = new ethers.providers.JsonRpcProvider();
            const contract = fetchContract(provider);

            const shipments = await contract.getAllTransactions();
            const allShipments = shipments.map((shipment) => ({
                sender: shipment.sender,
                receiver: shipment.receiver,
                price: ethers.utils.formatEther(shipment.price.toString()),
                pickupTime: shipment.pickupTime.toNumber(),
                isPaid: shipment.isPaid,
                status: shipment.status,
            }));

            return allShipments;
        } catch (error) {
            console.log("error want, getting shipment");
        }
    };
     
    const getShipmentCount = async () => {
        try {
            if (!window.ethereum) return "Install MetaMask";

            const accounts = 
        }
    }
}

