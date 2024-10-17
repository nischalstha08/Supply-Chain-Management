// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Tracking {
    enum ShipmentStatus { PENDING, IN_TRANSIT, DELIVERED }

    struct Shipment {
        address sender;
        address receiver;
        uint256 pickupTime;
        uint256 deliveryTime;
        uint256 distance;
        uint256 price;
        ShipmentStatus status;
        bool isPaid;
    }

    mapping(address => Shipment[]) public shipments;
    uint256 public shipmentCount;

    struct TypeShipment {
        address sender;
        address receiver;
        uint256 pickupTime;
        uint256 deliveryTime;
        uint256 distance;
        uint256 price;
        ShipmentStatus status;
        bool isPaid;
    }

    TypeShipment[] public tyepshipments;

    event ShipmentCreated(address indexed sender, address indexed receiver, uint256 pickupTime, uint256 distance, uint256 price);
    event ShipmentInTransit(address indexed sender, address indexed receiver, uint256 pickupTime);
    event ShipmentDelivered(address indexed sender, address indexed receiver, uint256 deliveryTime);
    event ShipmentPaid(address indexed sender, address indexed receiver, uint256 amount);

    constructor() {
        shipmentCount = 0;
    }

    function createShipment(address _receiver, uint256 _pickupTime, uint256 _distance, uint256 _price) external payable {
        require(msg.value == _price, "Payment amount must match the price.");
        
        Shipment memory shipment = Shipment({
            sender: msg.sender,
            receiver: _receiver,
            pickupTime: _pickupTime,
            deliveryTime: 0,
            distance: _distance,
            price: _price,
            status: ShipmentStatus.PENDING,
            isPaid: false
        });

        shipments[msg.sender].push(shipment);
        shipmentCount++;

        tyepshipments.push(TypeShipment({
            sender: msg.sender,
            receiver: _receiver,
            pickupTime: _pickupTime,
            deliveryTime: 0,
            distance: _distance,
            price: _price,
            status: ShipmentStatus.PENDING,
            isPaid: false
        }));

        emit ShipmentCreated(msg.sender, _receiver, _pickupTime, _distance, _price);
    }

    function startShipment(address _sender, address _receiver, uint256 _index) external {
        Shipment storage shipment = shipments[_sender][_index];
        require(shipment.receiver == _receiver, "Invalid receiver.");
        require(shipment.status == ShipmentStatus.PENDING, "Shipment is already in transit.");

        shipment.status = ShipmentStatus.IN_TRANSIT;
        tyepshipments[_index].status = ShipmentStatus.IN_TRANSIT;

        emit ShipmentInTransit(_sender, _receiver, shipment.pickupTime);
    }

    function completeShipment(address _sender, address _receiver, uint256 _index) external {
        Shipment storage shipment = shipments[_sender][_index];
        TypeShipment storage typeShipment = tyepshipments[_index];

        require(shipment.receiver == _receiver, "Invalid receiver.");
        require(shipment.status == ShipmentStatus.IN_TRANSIT, "Shipment not in transit.");
        require(!shipment.isPaid, "Shipment already paid");

        shipment.status = ShipmentStatus.DELIVERED;
        typeShipment.status = ShipmentStatus.DELIVERED;
        shipment.deliveryTime = block.timestamp;
        typeShipment.deliveryTime = block.timestamp;

        uint256 amount = shipment.price;
        payable(shipment.sender).transfer(amount);

        shipment.isPaid = true;
        typeShipment.isPaid = true;

        emit ShipmentDelivered(_sender, _receiver, shipment.deliveryTime);
        emit ShipmentPaid(_sender, _receiver, amount);
    }

    function getShipment(address _sender, uint256 _index) external view returns (Shipment memory) {
        return shipments[_sender][_index];
    }

    function getShipmentsCount(address _sender) external view returns (uint256) {
        return shipments[_sender].length;
    }

    function getAllTransactions() external view returns (TypeShipment[] memory) {
        return tyepshipments;
    }
}
