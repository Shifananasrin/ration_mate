from django.urls import path
from .views import (
    RationUserViewSet,
    add_update_shop,          # Admin add/update shop
    add_update_stock,         # Admin add/update stock
    home_menu,
    owner_login,
    create_owner_password,
    change_owner_password,
    add_monthly_entitlement,
    view_monthly_entitlements,
    view_stock,               # Users view stock
    view_shop_status,         # Users view shop status
    submit_complaint,         # Users submit complaint
    view_all_complaints           # Users view their complaints
)

# User actions using DRF ViewSet
check_phone = RationUserViewSet.as_view({'post': 'check_phone'})
verify_otp = RationUserViewSet.as_view({'post': 'verify_otp'})
resend_otp = RationUserViewSet.as_view({'post': 'resend_otp'})
card_details = RationUserViewSet.as_view({'get': 'card_details'})

urlpatterns = [
    # -------------------- User endpoints --------------------
    path('users/', RationUserViewSet.as_view({'get': 'list', 'post': 'create'}), name='user-list'),
    path('users/<int:pk>/card_details/', card_details, name='card-details'),
    path('users/<int:pk>/home_menu/', home_menu, name='home-menu'),
    path('users/check_phone/', check_phone, name='check-phone'),
    path('users/verify_otp/', verify_otp, name='verify-otp'),
    path('users/resend_otp/', resend_otp, name='resend-otp'),

    # -------------------- Owner endpoints --------------------
    path('owner/login/', owner_login, name='owner-login'),
    path('owner/create-password/', create_owner_password, name='create-owner-password'),
    path('owner/change-password/', change_owner_password, name='change-owner-password'),

    # -------------------- Entitlement endpoints --------------------
    path('entitlement/add/', add_monthly_entitlement, name='add-monthly-entitlement'),
    path('entitlement/list/', view_monthly_entitlements, name='view-monthly-entitlement'),

    # -------------------- Stock endpoints --------------------
    path('admin/stock/', add_update_stock, name='admin-add-update-stock'),  # Admin add/update stock
    path('user/stock/', view_stock, name='user-view-stock'),               # User view stock by shop_code & card_type
    # Example usage: GET /user/stock/?shop_code=S001&card_type=APL

    # -------------------- Shop endpoints --------------------
    path('admin/shop/', add_update_shop, name='admin-add-update-shop'),    # Admin add/update shop
    path('user/shop-status/', view_shop_status, name='user-view-shop-status'),  # User view shop status by shop_place
    # Example usage: GET /user/shop-status/?shop_place=Delhi

    # -------------------- Complaint endpoints --------------------
    path('complaints/submit/', submit_complaint, name='submit-complaint'),      # User submit complaint
    path('complaints/my/all', view_all_complaints, name='view-my-complaints'),        # User view their complaints
]
