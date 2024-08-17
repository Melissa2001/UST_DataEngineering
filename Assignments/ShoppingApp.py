print("Welcome to the Demo Marketplace")
user_db={"username":"Melissa","password":"Chakki"}
admin_db={"username":"Vivek","password":"Hailey"}
def user_login():
    username=input("Enter the username of the user: ")
    password=input("Enter the password of the user: ")
    if(username==user_db["username"] and password==user_db["password"]):
        print("Login successful as user")
    else:
        print("Login failed")
def admin_login():
    username=input("Enter the username of the user: ")
    password=input("Enter the password of the user: ")
    if(username==admin_db["username"] and password==admin_db["password"]):
        print("Login successful as admin")
    else:
        print("Login failed")
def generate_session_id():
    return "12345"
choice=input("""Are you an admin or user?(Input "admin"/"user")""")
if choice.lower()=="user":
    user_login()
elif choice.lower()=="admin":
    admin_login()
else:
    print("Invalid")
category=["footwear","clothing","electronics"]
catalog=[{"id":1, "name":"Adidas", "category":"footwear", "price":"10000"},
         {"id":2, "name":"Chanel", "category":"clothing", "price":"50000"},
         {"id":3, "name":"Apple", "category":"electronics", "price":"100000"}]
def display_catalog():
    print("id\tname\tcategory\tprice")
    for i in catalog:
        print(i['id'],"\t",i['name'],i['category'],"\t",i['price'],end="\t")
        print("\n")
cart=[] #Create an empty list named cart to represent the user's cart
def display_cart():
    #Display the items in the cart
    for i in cart:
        print(i)
def add_to_cart():
    #Add items to the cart with session ID, product ID, and quantity
    session_id=generate_session_id()
    product_id=int(input("Enter the item id from catalog: "))
    quantity=int(input("Enter the quantity needed"))
    cart.append({"session_id":session_id,"product_id":product_id,"quantity":quantity})
def delete_from_cart():
    #Remove items from the cart using session ID and product ID
    product_id=int(input("Enter the product id to delete: "))
    for i in cart:
        if(i['product_id']==product_id):
            cart.remove(i)
            print("Removed from cart")
def Add_Product():
    id=int(input("Enter the id of the product: "))
    name=input("Enter the name of the product: ")
    print("Enter the category of the product: ")
    print(category)
    input_category=input()
    price=input("Enter the price of the product: ")
    catalog.append({"id":id,"name":name,"category":input_category,"price":price})
def Modify_Product():
    id=int(input("Enter the id of the product to be modified: "))
    key=input("Enter the key to be modified(name,category,price)")
    modified=input("Enter the new value")
    for i in catalog:
        if(i['id']==id):
            i[key]=modified 
def Remove_Product():
    id=int(input("Enter the id of the product to be deleted: "))
    for i in catalog:
        if(i['id']==id):
            catalog.remove(i)
def Add_Category():
    new_category=input("Enter the new category name: ")
    category.append(new_category)
    print(category)
def Remove_Category():
    new_category=input("Enter the category to delete: ")
    category.remove(new_category)
    print(category)
if(choice=="user"):
    while(True):
        option=int(input("Enter your choice: 1. Display cart 2. Add to cart 3. Delete from cart 4. Log out"))
        if(option==1):
            display_cart()
        elif(option==2):
            add_to_cart()
        elif(option==3):
            delete_from_cart()
        elif(option==4):
            print("Thank you")
            break
        else:
            print("Invalid")
    def checkout():
        payment=int(input("Enter a payment method('1. UPI / 2. Debit cards')"))
        if(payment==1 or payment==2):
            print("Payment successful")
        else:
            print("Payment unsuccessfull. Redirecting")
            checkout()
    checkout()
elif(choice=="admin"):
    while(True):
        option=int(input("Enter your choice: 1. View Catalog 2. Add product 3. Modify product 4. Remove product 5. Add category 6. Remove category 7. Logout"))
        if(option==1):
            display_catalog()
        elif(option==2):
            Add_Product()
        elif(option==3):
            Modify_Product()
        elif(option==4):
            Remove_Product()
        elif(option==5):
            Add_Category()
        elif(option==6):
            Remove_Category()
        elif(option==7):
            print("Logging out")
            break
        else:
            print("Invalid")