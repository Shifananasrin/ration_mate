import random
import threading

def send_otp(user):
    """
    Generates OTP, saves it to the user, 
    and sends it asynchronously (offline mode prints to console)
    """
    otp = str(random.randint(100000, 999999))
    user.otp_code = otp
    user.save()  # save OTP to DB immediately

    # Asynchronous "sending" (for offline/testing)
    def async_send():
        print(f"OTP for {user.phone_number}: {otp}")  # offline OTP

    threading.Thread(target=async_send).start()

    return otp  # return OTP immediately to views
