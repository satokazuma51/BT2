// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AIModelMarketplace {
    struct Model {
        string name;
        string description;
        uint256 price;
        address payable creator;
        uint256 totalRating;
        uint256 ratingCount;
        uint256 rating; // Average rating (optional for convenience)
    }

    address public owner;
    uint256 public modelCount;
    mapping(uint256 => Model) public models;
    mapping(uint256 => mapping(address => bool)) public hasPurchased;

    event ModelListed(uint256 modelId, string name, address creator);
    event ModelPurchased(uint256 modelId, address buyer, uint256 price);
    event ModelRated(uint256 modelId, uint8 rating, address rater);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function listModel(string memory name, string memory description, uint256 price) public {
        modelCount++;
        models[modelCount] = Model({
            name: name,
            description: description,
            price: price,
            creator: payable(msg.sender),
            totalRating: 0,
            ratingCount: 0,
            rating: 0
        });

        emit ModelListed(modelCount, name, msg.sender);
    }

    function purchaseModel(uint256 modelId) public payable {
        require(modelId > 0 && modelId <= modelCount, "Invalid model ID");
        Model storage model = models[modelId];
        require(msg.value == model.price, "Incorrect payment amount");

        model.creator.transfer(msg.value);
        hasPurchased[modelId][msg.sender] = true;

        emit ModelPurchased(modelId, msg.sender, msg.value);
    }

    function rateModel(uint256 modelId, uint8 rating) public {
        require(modelId > 0 && modelId <= modelCount, "Invalid model ID");
        require(hasPurchased[modelId][msg.sender], "You must purchase the model first");
        require(rating >= 1 && rating <= 5, "Rating should be between 1 and 5");

        Model storage model = models[modelId];
        model.totalRating += rating;
        model.ratingCount++;
        model.rating = model.totalRating / model.ratingCount;

        emit ModelRated(modelId, rating, msg.sender);
    }

    function withdrawFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function getModelDetails(uint256 modelId)
    public
    view
    returns (string memory, string memory, uint256, address, uint256)
    {
        require(modelId > 0 && modelId <= modelCount, "Invalid model ID");
        Model memory model = models[modelId];
        return (model.name, model.description, model.price, model.creator, model.rating);
    }

    receive() external payable {}
}