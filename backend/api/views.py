import random
import string
from rest_framework import generics, permissions
from django.utils import timezone
from rest_framework import viewsets, filters, status
from rest_framework.response import Response
from django.contrib.auth.hashers import make_password
from rest_framework.permissions import IsAdminUser
from rest_framework.decorators import action, api_view
from rest_framework.views import APIView
from django.views.decorators.csrf import csrf_exempt

from .models import RationUser
from .serializers import (
    UserSerializer, HomeMenuSerializer,OwnerSerializer
) 
from django.shortcuts import render, redirect
from django.contrib import messages
#from .forms import EntitlementForm
from django.utils.timezone import now

from . import serializers

# -------------------
# Helper function
# -------------------
def generate_otp():
    """Generate a random 6-digit OTP."""
    return f"{random.randint(100000, 999999)}"

# -------------------
# RationUser ViewSet
# -------------------
class RationUserViewSet(viewsets.ModelViewSet):
    queryset = RationUser.objects.all()
    serializer_class = UserSerializer
    filter_backends = [filters.SearchFilter]
    search_fields = ['cardholder_name', 'phone_number', 'card_number']

    @action(detail=False, methods=['post'])
    def check_phone(self, request):
        phone_number = request.data.get('phone_number')
        if not phone_number:
            return Response({"error": "Phone number is required"}, status=status.HTTP_400_BAD_REQUEST)

        user = RationUser.objects.filter(phone_number=phone_number).first()
        exists = bool(user)
        otp = generate_otp()

        if user:
            user.otp_code = otp
            user.otp_created_at = timezone.now()
            user.save()

        return Response({"exists": exists, "user_id": user.id if user else None, "otp": otp})

    @action(detail=False, methods=['post'])
    def verify_otp(self, request):
        phone = request.data.get('phone_number')
        otp_code = request.data.get('otp_code')

        if not phone or not otp_code:
            return Response({'error': 'Phone number and OTP are required'}, status=status.HTTP_400_BAD_REQUEST)

        user = RationUser.objects.filter(phone_number=phone).first()
        if not user:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

        if user.otp_code == otp_code and user.otp_created_at and (timezone.now() - user.otp_created_at).seconds < 600:
            user.is_verified = True
            user.otp_code = None
            user.save()
            return Response({
                'success': True,
                'message': 'OTP verified successfully',
                'user_id': user.id
            })

        return Response({'success': False, 'message': 'Invalid or expired OTP'}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['post'])
    def resend_otp(self, request):
        phone_number = request.data.get('phone_number')
        if not phone_number:
            return Response({'error': 'Phone number is required'}, status=status.HTTP_400_BAD_REQUEST)

        user = RationUser.objects.filter(phone_number=phone_number).first()
        if not user:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

        otp = generate_otp()
        user.otp_code = otp
        user.otp_created_at = timezone.now()
        user.save()

        return Response({'success': True, 'otp': otp, 'message': 'New OTP sent successfully'})

    @action(detail=True, methods=['get'])
    def card_details(self, request, pk=None):
        user = self.get_object()
        data = {
            "cardholder_name": user.cardholder_name,
            "card_number": user.card_number,
            "phone_number": user.phone_number,
            "card_type": user.card_type,
            "address": user.address,
            "family_members": user.family_members,
            "ward_no": user.ward_no,
            "monthly_income": user.monthly_income,
            "taluk": user.taluk,
            "panchayath": user.panchayath,
            "district": user.district,
            "pincode": user.pincode,
        }
        return Response(data)

from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.hashers import check_password, make_password
from .models import Owner

# -------------------------------
# 1. Owner Login
# -------------------------------
@api_view(['POST'])
def owner_login(request):
    try:
        print("Request data:", request.data)
        admin_name = request.data.get('admin_name')
        password = request.data.get('password')

        if not admin_name or not password:
            return Response({"detail": "All fields required"}, status=400)

        try:
            owner = Owner.objects.get(admin_name=admin_name)
        except Owner.DoesNotExist:
            return Response({"detail": "Invalid admin_name or password"}, status=400)

        if not owner.check_password(password):
            return Response({"detail": "Invalid admin_name or password"}, status=400)

        return Response({"detail": "Login successful"}, status=200)

    except Exception as e:
        print("Login error:", e)
        return Response({"detail": "Internal server error"}, status=500)


# -------------------------------
# 2. Create Password (first-time)
# -------------------------------

from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Owner

@api_view(['POST'])
def create_owner_password(request):
    try:
        admin_name = request.data.get('admin_name')
        new_password = request.data.get('new_password')  # ✅ match Flutter key

        if not admin_name or not new_password:
            return Response({"detail": "All fields required"}, status=400)

        owner, created = Owner.objects.get_or_create(admin_name=admin_name)
        owner.set_password(new_password)  # ✅ use new_password
        owner.save()

        return Response({"detail": "Password created successfully"}, status=200)

    except Exception as e:
        print("Error:", e)
        return Response({"detail": "Internal server error"}, status=500)




# -------------------------------
# 3. Change Password (existing)
# -------------------------------@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def change_owner_password(request):

    admin_name = request.data.get('admin_name')
    old_password = request.data.get('old_password')
    new_password = request.data.get('new_password')

    if not admin_name or not old_password or not new_password:
        return Response({"detail": "All fields required"}, status=400)

    try:
        owner = Owner.objects.get(admin_name=admin_name)
    except Owner.DoesNotExist:
        return Response({"detail": "Invalid admin_name"}, status=400)

    if not owner.check_password(old_password):
        return Response({"detail": "Old password incorrect"}, status=400)

    owner.set_password(new_password)
    owner.save()  # <--- important

    return Response({"detail": "Password changed successfully"}, status=200)



# api/views.py
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Stock, Shop
from .serializers import StockSerializer, ShopSerializer

@api_view(['POST'])
def add_stock(request):
    serializer = StockSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response({"detail": "Stock added successfully"}, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
def get_shops(request):
    shops = Shop.objects.all()
    serializer = ShopSerializer(shops, many=True)
    return Response(serializer.data)







from rest_framework.decorators import api_view
from rest_framework.response import Response

@api_view(['GET'])
def home_menu(request, pk=None):
    """
    Example Home Menu endpoint.
    """
    # You can customize based on your logic
    data = {
        "message": "Home menu for user",
        "user_id": pk
    }
    return Response(data)



from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Entitlement
from .serializers import MonthlyEntitlementSerializer

@api_view(['POST'])
def add_monthly_entitlement(request):
    try:
        serializer = MonthlyEntitlementSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"detail": "Entitlement added successfully"}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        print("Error:", e)
        return Response({"detail": "Internal server error"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
@api_view(['GET'])
def view_monthly_entitlements(request):
    entitlements = Entitlement.objects.all().order_by('-id')
    serializer = MonthlyEntitlementSerializer(entitlements, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)



from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Shop, Stock
from .serializers import ShopSerializer, StockSerializer

# Admin: Add/Update Shop Status
@api_view(['POST'])
def add_update_shop(request):
    shop_code = request.data.get('shop_code')
    shop_place = request.data.get('shop_place')
    status_val = request.data.get('status', 'OPEN')

    shop, created = Shop.objects.update_or_create(
        shop_code=shop_code,
        defaults={'shop_place': shop_place, 'status': status_val}
    )
    serializer = ShopSerializer(shop)
    return Response(serializer.data, status=status.HTTP_200_OK)

# Admin: Add/Update Stock
@api_view(['POST'])
def add_update_stock(request):
    shop_code = request.data.get('shop_code')
    try:
        shop = Shop.objects.get(shop_code=shop_code)
    except Shop.DoesNotExist:
        return Response({"error": "Shop does not exist"}, status=status.HTTP_400_BAD_REQUEST)

    stock_id = request.data.get('id')
    if stock_id:
        # Update existing stock
        try:
            stock = Stock.objects.get(id=stock_id, shop=shop)
            stock.item_name = request.data.get('item_name', stock.item_name)
            stock.available_quantity = request.data.get('available_quantity', stock.available_quantity)
            stock.price = request.data.get('price', stock.price)
            stock.card_type = request.data.get('card_type', stock.card_type)
            stock.save()
        except Stock.DoesNotExist:
            return Response({"error": "Stock not found"}, status=status.HTTP_400_BAD_REQUEST)
    else:
        # Add new stock
        stock = Stock.objects.create(
            shop=shop,
            item_name=request.data['item_name'],
            available_quantity=request.data['available_quantity'],
            price=request.data['price'],
            card_type=request.data['card_type']
        )

    serializer = StockSerializer(stock)
    return Response(serializer.data, status=status.HTTP_200_OK)

# User: View Stock by Shop and Card Type
@api_view(['GET'])
def view_stock(request):
    shop_code = request.GET.get('shop_code')
    card_type = request.GET.get('card_type')
    stocks = Stock.objects.filter(shop__shop_code=shop_code, card_type=card_type)
    if not stocks.exists():
        return Response({"message": "No stock found for this shop and card type"}, status=status.HTTP_404_NOT_FOUND)
    serializer = StockSerializer(stocks, many=True)
    return Response(serializer.data)

# User: View Shop Status by Place
@api_view(['GET'])
def view_shop_status(request):
    shop_place = request.GET.get('shop_place')
    shops = Shop.objects.filter(shop_place__icontains=shop_place)
    if not shops.exists():
        return Response({"message": "No shop found for this place"}, status=status.HTTP_404_NOT_FOUND)
    serializer = ShopSerializer(shops, many=True)


    
    from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Complaint, RationUser
from .serializers import ComplaintSerializer

# ✅ Submit Complaint API
@api_view(['POST'])
def submit_complaint(request):
    phone = request.data.get('phone_number')

    if not phone:
        return Response({"error": "Phone number is required."}, status=status.HTTP_400_BAD_REQUEST)

    try:
        ration_user = RationUser.objects.get(phone_number=phone)
    except RationUser.DoesNotExist:
        return Response({"error": "RationUser not found for this phone number."}, status=status.HTTP_404_NOT_FOUND)

    serializer = ComplaintSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(ration_user=ration_user)  # Save complaint with linked user
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ✅ View All Complaints API (GET)
@api_view(['GET'])
def view_all_complaints(request):
    complaints = Complaint.objects.all().order_by('-id')
    serializer = ComplaintSerializer(complaints, many=True)
    return Response(serializer.data)

