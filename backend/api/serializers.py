from rest_framework import serializers
from .models import RationUser,HomeMenu,Owner,Stock,Shop

# ------------------
# User Serializer
# -------------------
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = RationUser
        fields = '__all__'

class HomeMenuSerializer(serializers.ModelSerializer):
    class Meta:
        model = HomeMenu
        fields = ['id', 'label', 'icon', 'route']

class OwnerSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False, min_length=6)
    confirm_password = serializers.CharField(write_only=True, required=False, min_length=6)

    class Meta:
        model = Owner
        fields = ['id', 'admin_name', 'password', 'confirm_password', 'is_active']

    def validate(self, data):
        password = data.get('password')
        confirm_password = data.get('confirm_password')
        if password or confirm_password:
            if password != confirm_password:
                raise serializers.ValidationError("Passwords do not match")
        return data

    def create(self, validated_data):
        password = validated_data.pop('password', None)
        owner = Owner(**validated_data)
        if password:
            owner.set_password(password)
        else:
            owner.set_unusable_password()
        owner.save()
        return owner

    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)
        instance.admin_name = validated_data.get('admin_name', instance.admin_name)
        instance.is_active = validated_data.get('is_active', instance.is_active)
        if password:
            instance.set_password(password)
        instance.save()
        return instance
    

    









from rest_framework import serializers
from .models import Entitlement

class MonthlyEntitlementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Entitlement
        fields = ['id', 'item_name', 'card_type', 'quantity', 'month', 'price', 'created_at']

#from rest_framework import serializers
from .models import Shop, Stock

class ShopSerializer(serializers.ModelSerializer):
    class Meta:
        model = Shop
        fields = ['id', 'shop_code', 'shop_place', 'status']

class StockSerializer(serializers.ModelSerializer):
    shop_code = serializers.CharField(source='shop.shop_code', read_only=True)
    shop_place = serializers.CharField(source='shop.shop_place', read_only=True)

    class Meta:
        model = Stock
        fields = ['id', 'item_name', 'available_quantity', 'price', 'card_type', 'shop_code', 'shop_place']



from rest_framework import serializers
from .models import Complaint


from rest_framework import serializers
from .models import Complaint, RationUser

class ComplaintSerializer(serializers.ModelSerializer):
    cardholder_name = serializers.CharField(source='ration_user.cardholder_name', read_only=True)  # ✅ show user name

    class Meta:
        model = Complaint
        fields = ['id', 'title', 'description', 'status', 'created_at', 'updated_at', 'cardholder_name']
        read_only_fields = ['status', 'created_at', 'updated_at', 'cardholder_name']  # ✅ these should not be editable


