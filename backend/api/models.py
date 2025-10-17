from django.db import models
from django.utils import timezone
from django.core.validators import RegexValidator
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager

import datetime


# -------------------
# User Model
# -------------------
class RationUser(models.Model):
    CARD_TYPE_CHOICES = [
        ('APL', 'APL'),
        ('BPL', 'BPL'),
        ('AAY', 'AAY'),
        ('PHH', 'PHH'),
    ]

    LANGUAGE_CHOICES = [
        ('en', 'English'),
        ('ml', 'Malayalam'),
    ]

    cardholder_name = models.CharField(max_length=100, blank=True, null=True)
    card_type = models.CharField(max_length=10, choices=CARD_TYPE_CHOICES, blank=True, null=True)
    card_number = models.CharField(max_length=20, unique=True, blank=True, null=True)
    phone_number = models.CharField(max_length=15, unique=True)
    address = models.TextField(blank=True, null=True)
    family_members = models.IntegerField(default=1)
    ward_no = models.IntegerField(blank=True, null=True)
    monthly_income = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    taluk = models.CharField(max_length=50, blank=True, null=True)
    panchayath = models.CharField(max_length=100, null=True, blank=True)
    district = models.CharField(max_length=100, blank=True, null=True)
    panchayath = models.CharField(max_length=100, null=True, blank=True)
    pincode = models.CharField(max_length=10, blank=True, null=True)
    language_preference = models.CharField(max_length=5, choices=LANGUAGE_CHOICES, default='en')
    otp_code = models.CharField(max_length=6, blank=True, null=True, validators=[RegexValidator(r'^\d{6}$')])
    otp_created_at = models.DateTimeField(blank=True, null=True)
    is_verified = models.BooleanField(default=False)


    def __str__(self):
        return f"{self.cardholder_name} ({self.phone_number})"

    def is_otp_valid(self):
        if self.otp_code and self.otp_created_at:
            return timezone.now() - self.otp_created_at < datetime.timedelta(minutes=5)
        return False



class HomeMenu(models.Model):
    label = models.CharField(max_length=255)
    icon = models.CharField(max_length=100)
    route = models.CharField(max_length=100)

    def __str__(self):
        return self.label


from django.db import models
from django.contrib.auth.hashers import make_password, check_password

class Owner(models.Model):
    admin_name = models.CharField(max_length=100, unique=True)
    password = models.CharField(max_length=255, blank=True, null=True)  # hashed password
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return self.admin_name

    # -------------------------------
    # Set password (hash)
    # -------------------------------
    def set_password(self, raw_password):
        self.password = make_password(raw_password)
        self.save(update_fields=['password'])

    # -------------------------------
    # Check password
    # -------------------------------
    def check_password(self, raw_password):
        if not self.password:
            return False
        return check_password(raw_password, self.password)






class Entitlement(models.Model):
    item_name = models.CharField(max_length=100)
    card_type = models.CharField(max_length=50)
    quantity = models.PositiveIntegerField()
    month = models.CharField(max_length=20)  # Could also use DateField for more precision
    price = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.item_name} - {self.card_type} ({self.month})"
    


from django.db import models

# ----------------------------
# Card Types
# ----------------------------
CARD_TYPES = (
    ('BPL', 'BPL'),
    ('APL', 'APL'),
    ('PHH', 'PHH'),
)

from django.db import models

CARD_CHOICES = (
    ('APL', 'APL'),
    ('BPL', 'BPL'),
)

STATUS_CHOICES = (
    ('OPEN', 'Open'),
    ('CLOSED', 'Closed'),
)

class Shop(models.Model):
    shop_code = models.CharField(max_length=20, unique=True)
    shop_place = models.CharField(max_length=100)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='OPEN')

    def __str__(self):
        return f"{self.shop_code} - {self.shop_place}"

class Stock(models.Model):
    shop = models.ForeignKey(Shop, on_delete=models.CASCADE, related_name='stocks')
    item_name = models.CharField(max_length=100)
    available_quantity = models.PositiveIntegerField()
    price = models.FloatField()
    card_type = models.CharField(max_length=10, choices=CARD_CHOICES)

    def __str__(self):
        return f"{self.item_name} ({self.shop.shop_code})"




from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

STATUS_CHOICES = (
    ('PENDING', 'Pending'),
    ('RESOLVED', 'Resolved'),
    ('Rejected', 'Rejected'),

)

class Complaint(models.Model):

    ration_user = models.ForeignKey(RationUser, on_delete=models.CASCADE) 
    title = models.CharField(max_length=200)
    description = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
