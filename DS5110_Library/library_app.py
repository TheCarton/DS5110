# Luke Van Der Male

# Importing module
from datetime import date, datetime

import mysql.connector
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Creating connection object
db = mysql.connector.connect(
	host = "localhost",
	user = "root",
	password = "9320",
    database = "library"
)



def interface():
    """Main interface for app"""
    end_app = False
    while end_app != True:
        print("Welcome to Anachronistic Library App! \n \n")
        print("Enter a number to choose an option: ")
        print("1) Add a new patron")
        print("2) Check a book out")
        print("3) Return a book")
        print("4) Search for a book")
        print("5) Delete a member")
        print("6) Check a member's account")
        print("7) Modify a member's account")
        print("9) Quit")

        choice = None
        while choice not in [1, 2, 3, 4, 5, 6, 7, 9]:
            choice = int(input("Enter an integer choice: "))
        if choice == 1:
            add_patron_prompt()
        elif choice == 2:
            lend_prompt()
        elif choice == 3:
            return_book_prompt()
        elif choice == 4:
            search_book_prompt()
        elif choice == 5:
            delete_member_prompt()
        elif choice == 6:
            check_member_prompt()
        elif choice == 7:
            update_member_prompt()
        elif choice in [1, 2, 3, 4, 5, 6, 7]:
            interface()
        elif choice == 9:
            end_app = True

def data_mine():
    my_data = pd.read_sql("SELECT * FROM books", db)
    plt.style.use('seaborn-dark-palette')
    d = np.polyfit(my_data['num_pages'], my_data['average_rating'], 1)
    f = np.poly1d(d)
    my_data.insert(12, 'R_num_pages', f(my_data['num_pages']))
    ax = my_data.plot(kind = "scatter", x = "num_pages", y = "average_rating", marker=".")
    my_data.plot(x = 'num_pages', y = 'R_num_pages', color='Red', ax=ax)
    
    plt.show()

def add_patron_prompt():
    patron_id = int(input("Enter patron ID (max 5 characters): "))
    patron_name = str(input("Enter patron name: "))
    patron_phone = str(input("Enter phone number: "))
    add_patron(patron_id, patron_name, patron_phone)


def add_patron(patron_id, patron_name, patron_phone):
    """Transaction 1: Add a patron to the database."""
    cursor = db.cursor()
    sql = "INSERT INTO patrons (ID, name, status, phone) VALUES (%s, %s, %s, %s);"
    val_tuple = (patron_id, patron_name, "good", patron_phone)
    try:
        cursor.execute(sql, val_tuple)
        db.commit()

    except Exception as e:
        db.rollback()
        raise e

def search_book_prompt():
    bookID = int(input("Enter book ID number: "))
    search_book(bookID)

def search_book(bookID):
    cursor = db.cursor()
    search_sql = "SELECT * FROM books WHERE bookID = {};".format(bookID)
    cursor.execute(search_sql)
    row = cursor.fetchone()
    for item in row:
        print(item)

def check_member_prompt():
    ID = int(input("Enter member ID: "))
    check_patron(ID)


def check_patron(ID):
    """List books checked out by patron and any fees"""
    cursor = db.cursor()
    search_sql = "SELECT * FROM patrons WHERE ID = {};".format(ID)
    cursor.execute(search_sql)
    row = cursor.fetchone()
    print("Account: ")
    for item in row:
        print(item)

def book_quantity_prompt():
    bookID = int(input("Enter book identification number: "))
    quantity = int(input("Enter number of books received: "))
    update_book_quantity(bookID, quantity)
    

def update_book_quantity(bookID, quantity):
    """Admin to manipulate book entry"""
    cursor = db.cursor()
    search_sql = "UPDATE bookitem SET quantity = quantity + {} WHERE bookID = {};".format(quantity, bookID)
    cursor.execute(search_sql)

def delete_member_prompt():
    ID = int(input("Enter ID of member to delete: "))
    delete_member(ID)

def delete_member(ID):
    """Admin to delete patron entry"""
    cursor = db.cursor()
    try:
        delete_sql = "DELETE FROM patrons WHERE ID = {};".format(ID)
        cursor.execute(delete_sql)
        db.commit()
    except Exception as e:
        db.rollback()
        raise e

def update_member_prompt():
    ID = int(input("Enter ID of patron to modify: "))
    name = str(input("Enter patron name: "))
    status = str(input("Enter patron status: "))
    phone = str(input("Enter patron phone: "))
    fee = float(input("Enter patron fee: "))
    update_member(name, status, phone, fee, ID)



def update_member(name, status, phone, fee, ID):
    """Admin to manipulate patron entry"""
    cursor = db.cursor()
    try:
        update_sql = "UPDATE patrons SET name = '{}', status = '{}', phone = '{}', fee = {} WHERE ID = {};".format(name, status, phone, fee, ID)
        cursor.execute(update_sql)
        db.commit()
    except Exception as e:
        db.rollback()
        raise e

def lend_prompt():
    """Get user input to lend book."""
    patron_id = str(input("Enter patron ID (max 5 characters): "))
    book_id = str(input("Enter book ID: "))
    current_date = date.today()
    date_string = "{}-{}-{}".format(current_date.year, current_date.month, current_date.day)
    lend_book(patron_id, book_id, date_string)

def get_status(ID):
    """Check patron for account status"""
    cursor = db.cursor()
    insert_sql = "SELECT status FROM patrons WHERE ID = {};".format(ID)
    cursor.execute(insert_sql)
    status = cursor.fetchone()[0]
    return status

def lend_book(patron_id, book_id, lend_date):
    """Transaction 2: Add a book to the database."""
    status = get_status(patron_id)
    if status == "hold":
        print("Account {} is on hold.".format(patron_id))
        return
    cursor = db.cursor()
    insert_sql = "INSERT INTO lending (ID, item_id, date) VALUES (%s, %s, str_to_date(%s, '%Y-%d-%m'));"
    val_tuple = (patron_id, book_id, lend_date)
    try:
        cursor.execute(insert_sql, val_tuple)
        db.commit()

    except Exception as e:
        db.rollback()
        raise e

def return_book_prompt():
    item_id = int(input("Enter item ID of book: "))
    return_book(item_id)
    print("returned book number: {} succesfully.".format(item_id))


def getDifference(then, now = date.today()):
    """Find interval between dates. Function adapted from DelftStack."""

    duration = now - then
    duration_in_s = duration.total_seconds() 
    
    #Date and Time constants
    day_ct = 24 * 60 * 60 			#86400
    
    def days():
      return divmod(duration_in_s, day_ct)[0]

    return int(days())

def assess_fee(days_out):
    """Return fee given number of days item has been out"""
    if days_out <= 28:
        return float(0)
    elif days_out <= 56:
        return float(4.99)
    else:
        return float(15)

def return_book(item_id):
    """return a book and remove it from patron's account"""
    cursor = db.cursor()
    lend_query = "SELECT ID, date FROM lending WHERE item_id = {};".format(item_id)
    cursor.execute(lend_query)
    result = cursor.fetchone()
    id = result[0]
    date_lent = result[1]
    days_out = getDifference(date_lent)
    fee = assess_fee(days_out)

    try:
        delete_sql = "DELETE FROM lending WHERE item_id = {};".format(item_id)
        cursor.execute(delete_sql)
        db.commit()

        update_sql = "UPDATE patrons SET status = 'good', fee = fee + {} WHERE ID = {};".format(fee, id)
        cursor.execute(update_sql)
        db.commit()

    except Exception as e:
        db.rollback()
        raise e

def bug_check():
    """Convenience method to check functionaliy"""
    add_patron(100, "joe", "11111111")
    update_member("bill", "good", "123", 0.0, 100)
    lend_book(100, 166, "2021-15-12")
    get_status(100)
    return_book(166)
    delete_member(100)


def main():
    interface()

if __name__ == "__main__":
    main()
