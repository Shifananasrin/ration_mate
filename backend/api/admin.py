from django.contrib import admin
from django import forms
from django.contrib.auth.hashers import make_password

# Import your models
from .models import Complaint, RationUser, Owner, Entitlement, Shop, Stock

# -------------------
# 1. User Admin (Unregister if already registered)
# -------------------
try:
    admin.site.unregister(RationUser)
except admin.sites.NotRegistered:
    pass

@admin.register(RationUser)
class RationUserAdmin(admin.ModelAdmin):
    list_display = ('cardholder_name', 'phone_number', 'card_type', 'district', 'language_preference')
    search_fields = ('cardholder_name', 'phone_number', 'card_number')
    list_filter = ('card_type', 'district', 'language_preference')
    ordering = ('cardholder_name',)

# -------------------
# 2. Owner Admin Forms
# -------------------
class OwnerCreationForm(forms.ModelForm):
    password1 = forms.CharField(label="Password", widget=forms.PasswordInput, required=False)
    password2 = forms.CharField(label="Confirm Password", widget=forms.PasswordInput, required=False)

    class Meta:
        model = Owner
        fields = ['admin_name', 'is_active']

    def clean(self):
        cleaned_data = super().clean()
        password1 = cleaned_data.get("password1")
        password2 = cleaned_data.get("password2")
        if password1 or password2:
            if password1 != password2:
                raise forms.ValidationError("Passwords do not match")
        return cleaned_data

    def save(self, commit=True):
        owner = super().save(commit=False)
        password1 = self.cleaned_data.get("password1")
        if password1:
            owner.password = make_password(password1)
        if commit:
            owner.save()
        return owner

class OwnerChangeForm(forms.ModelForm):
    password = forms.CharField(label="Password (hashed)", widget=forms.TextInput, required=False, disabled=True)

    class Meta:
        model = Owner
        fields = ['admin_name', 'password', 'is_active']

# -------------------
# 3. Owner Admin
# -------------------
class OwnerAdmin(admin.ModelAdmin):
    form = OwnerChangeForm
    add_form = OwnerCreationForm

    list_display = ('admin_name', 'is_active')
    search_fields = ('admin_name',)
    ordering = ('admin_name',)

    fieldsets = (
        (None, {'fields': ('admin_name', 'password', 'is_active')}),
    )

    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('admin_name', 'password1', 'password2', 'is_active')}
        ),
    )

admin.site.register(Owner, OwnerAdmin)

# -------------------
# 4. Entitlement Admin
# -------------------
@admin.register(Entitlement)
class EntitlementAdmin(admin.ModelAdmin):
    list_display = ('item_name', 'card_type', 'quantity', 'month', 'price')
    search_fields = ('item_name', 'card_type', 'month')
    list_filter = ('card_type', 'month')

# -------------------
# 5. Shop Admin
# -------------------
@admin.register(Shop)
class ShopAdmin(admin.ModelAdmin):
    list_display = ('shop_code', 'shop_place', 'status')
    list_filter = ('status', 'shop_place')
    search_fields = ('shop_code', 'shop_place')
    ordering = ('shop_code',)

# -------------------
# 6. Stock Admin
# -------------------
@admin.register(Stock)
class StockAdmin(admin.ModelAdmin):
    list_display = ('item_name', 'shop_code_display', 'shop_place_display', 'available_quantity', 'price', 'card_type')
    list_filter = ('card_type', 'shop__shop_place')
    search_fields = ('item_name', 'shop__shop_code', 'shop__shop_place')
    ordering = ('shop', 'item_name')

    def shop_code_display(self, obj):
        return obj.shop.shop_code
    shop_code_display.short_description = 'Shop Code'

    def shop_place_display(self, obj):
        return obj.shop.shop_place
    shop_place_display.short_description = 'Shop Place'

# -------------------
# 7. Complaint Admin
# -------------------

@admin.register(Complaint)
class ComplaintAdmin(admin.ModelAdmin):
    list_display = ('id', 'ration_user', 'title', 'status', 'created_at')
    list_filter = ('status', 'created_at')
    search_fields = ('title', 'description', 'user__cardholder_name', 'user__phone_number')
    ordering = ('-created_at',)
    readonly_fields = ('created_at', 'updated_at')
