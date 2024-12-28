// 1.1 Create the collections

	db.createCollection("customers");
	
	db.createCollection("orders");
	
	db.customers.insertMany([
	  {
		"name": "abhi", 
		"email": "abhigna@example.com", 
		"address": { "street": "2nd  Main St", "city": "Sanatha circle", "zipcode": "12345" }, 
		"phone": "123-1234", 
		"registration_date": ISODate("2023-01-06T12:00:00Z")
	  },
	  {
		"name": "Kavya",
		"email": "bojjakavyas@gmail.com",
		"address": { "street": "Sanjeev nagar", "city": "Tadipatri", "zipcode": "515411" },
		"phone": "123456789",
		"registration_date": ISODate("2023-02-06T09:30:00Z")
	  },
	  {
		"name": "Rohitraj",
		"email": "Rohitraj@gamil.com",
		"address": { "street": "234", "city": "Patna", "zipcode": "515346" },
		"phone": "123456789",
		"registration_date": ISODate("2023-03-06T14:15:00Z")
	  },
	  {
		"name": "Swapna",
		"email": "Swapnachinni@gmail.com",
		"address": { "street": "100", "city": "hyderabad", "zipcode": "123456" },
		"phone": "123456789",
		"registration_date": ISODate("2023-04-06T16:45:00Z")
	  },
	  {
		"name": "Rishi",
		"email": "rishi@gamil.com",
		"address": { "street": "101", "city": "chennai", "zipcode": "100111" },
		"phone": "123456789",
		"registration_date": ISODate("2023-05-06T11:00:00Z")
	  }
	]);
	
	db.orders.insertMany([
		  {
			"order_id": "ORD123456", 
			"customer_id": ObjectId('673334589a8600cc95d9e08d'), 
			"order_date": ISODate("2023-05-15T14:00:00Z"), 
			"status": "shipped", 
			"items": [ 
				{ "product_name": "Rice cooker", "quantity": 1, "price": 1500 }, 
				{ "product_name": "Phone", "quantity": 2, "price": 25 } 
			], 
			"total_value": 1550 
		  },
		  {
			"order_id": "ORD123457",
			"customer_id": ObjectId('673334589a8600cc95d9e08e'),
			"order_date": ISODate("2023-06-10T10:30:00Z"),
			"status": "processing",
			"items": [
			  { "product_name": "Tablet", "quantity": 1, "price": 300 },
			  { "product_name": "Keyboard", "quantity": 1, "price": 50 }
			],
			"total_value": 350
		  },
		  {
			"order_id": "ORD123458",
			"customer_id": ObjectId('673334589a8600cc95d9e08f'),
			"order_date": ISODate("2023-07-05T12:15:00Z"),
			"status": "shipped",
			"items": [
			  { "product_name": "Smartphone", "quantity": 1, "price": 800 },
			  { "product_name": "Charger", "quantity": 2, "price": 25 }
			],
			"total_value": 850
		  },
		  {
			"order_id": "ORD123459",
			"customer_id": ObjectId('673334589a8600cc95d9e090'),
			"order_date": ISODate("2023-08-20T15:00:00Z"),
			"status": "delivered",
			"items": [
			  { "product_name": "Monitor", "quantity": 1, "price": 200 },
			  { "product_name": "HDMI Cable", "quantity": 1, "price": 15 }
			],
			"total_value": 215
		  },
		  {
			"order_id": "ORD123460",
			"customer_id": ObjectId('673334589a8600cc95d9e091'),
			"order_date": ISODate("2023-09-10T09:00:00Z"),
			"status": "pending",
			"items": [
			  { "product_name": "Headphones", "quantity": 2, "price": 100 },
			  { "product_name": "Mouse Pad", "quantity": 1, "price": 20 }
			],
			"total_value": 220
		  }
]);

// 1.2 Find Orders for a Specific Customer:
	
	db.orders.find({ "customer_id": ObjectId('673334589a8600cc95d9e08d')},  { "items": 1, "_id": 0 } );
	
// 1.3 Find the Customer for a Specific Order:
	
	let order = db.orders.findOne({ "order_id": "ORD123456" });
	db.customers.findOne({ "_id": order.customer_id });
	
// 1.4 Update Order Status:

	db.orders.updateOne({ "order_id": "ORD123456" }, { $set: { "status": "delivered" } });
	
// 1.5 Delete an Order:

	db.orders.deleteOne({ "order_id": "ORD123456" });
	
/* ----------------------------------------------------------------------------------------------------------- */

//2.1 Calculate Total Value of All Orders by Customer:

	db.orders.aggregate([
	  { $group: { _id: "customer_id", totalOrderValue: { $sum: "$total_value" } } },
	  { $lookup: { from: "customers", localField: "_id", foreignField: "_id", as: "customer_info" } },
	  { $project: { _id: 0, "customer_info.name": 1, totalOrderValue: 1 } }
	]);

//2.2. Group Orders by Status:

	db.orders.aggregate([
		{ $group: { _id: "$status" } }
	]);

//2.3. List Customers with Their Recent Orders:

	db.orders.aggregate([
	  { $sort: { "order_date": -1 } },
	  { $group: { _id: "customer_id" } },
	  { $lookup: { from: "customers", localField: "_id", foreignField: "_id", as: "customer_info" } },
	  { $project: { "customer_info.name": 1, "customer_info.email": 1, "recentOrder.order_id": 1, "recentOrder.total_value": 1 } }
	]);
	
//2.4. Find the Most Expensive Order by Customer:

	db.orders.aggregate([
	  { $sort: { "total_value": -1 } },
	  { $group: { _id: "$customer_id", mostExpensiveOrder: { $first: "$$ROOT" } } },
	  { $lookup: { from: "customers", localField: "_id", foreignField: "_id", as: "customer_info" } },
	  { $project: { "customer_info.name": 1, "mostExpensiveOrder.order_id": 1, "mostExpensiveOrder.total_value": 1 } }
	]);
	
	
/* ------------------------------------------------------------------------------------------------------------ */

//3.1 Find All Customers Who Placed Orders in the Last Month

	let lastMonth = ISODate("2023-07-05T12:15:00Z");

	db.orders.aggregate([
	  { $match: { "order_date": { $gte: lastMonth } } },
	  { $group: { _id: "$customer_id", recentOrderDate: { $max: "$order_date" } } },
	  { $lookup: { from: "customers", localField: "_id", foreignField: "_id", as: "customer_info" } },
	  { $project: { "customer_info.name": 1, "customer_info.email": 1, recentOrderDate: 1 } }
	]);


//3.2.	Find All Products Ordered by a Specific Customer:

	let customer = db.customers.findOne({ "name": "Kavya" });

	db.orders.aggregate([
	  { $match: { "customer_id": customer._id } },
	  { $group: { _id: "$items.product_name", totalQuantity: { $sum: "$items.quantity" } } }
	]);


//3.3. Find the Top 3 Customers with the Most Expensive Total Orders:

	db.orders.aggregate([
	  { $group: { _id: "$customer_id", totalOrderValue: { $sum: "$total_value" } } },
	  { $sort: { totalOrderValue: -1 } },
	  { $limit: 3 },
	  { $lookup: { from: "customers", localField: "_id", foreignField: "_id", as: "customer_info" } },
	  { $project: { "customer_info.name": 1, totalOrderValue: 1 } }
	]);


//3.4. Add a New Order for an Existing Customer:
	
	let customer = db.customers.findOne({ "name": "Kavya" });

	db.orders.insertOne({
	  "order_id": "ORD123457",
	  "customer_id": customer._id,
	  "order_date": ISODate("2023-11-12T10:00:00Z"),
	  "status": "pending",
	  "items": [
		{ "product_name": "Smartphone", "quantity": 1, "price": 800 },
		{ "product_name": "Headphones", "quantity": 1, "price": 150 }
	  ],
	  "total_value": 950
	});

	

/* ------------------------------------------------------------------------------------------------------------ */
//4.1. Find All Customers Who Placed Orders in the Last Month:

	db.customers.aggregate([
	  { $lookup: { from: "orders", localField: "_id", foreignField: "customer_id", as: "orders" } },
	  { $match: { "orders": { $size: 0 } } },
	  { $project: { "name": 1, "email": 1 } }
	]);
	
//4.2. Calculate the Average Number of Items Ordered per Order:

	db.orders.aggregate([
	  { $group: { _id: "$_id", itemCount: { $sum: 1 } } },
	  { $group: { _id: null, averageItemsPerOrder: { $avg: "$itemCount" } } },
	  { $project: { _id: 0, averageItemsPerOrder: 1 } }
	]);
	
//4.3. Join Customer and Order Data Using $lookup:

	db.orders.aggregate([
	  { $lookup: { from: "customers", localField: "customer_id", foreignField: "_id", as: "customer_info" } },
	  { $project: { "customer_info.name": 1, "customer_info.email": 1, "order_id": 1, "total_value": 1, "order_date": 1 } }
	]);