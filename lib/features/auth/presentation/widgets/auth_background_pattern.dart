import 'package:flutter/material.dart';

class AuthBackgroundPattern extends StatelessWidget {
  const AuthBackgroundPattern({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        final spacingX = 70.0;
        final spacingY = 70.0;
        final cols = (w / spacingX).ceil() + 1;
        final rows = (h / spacingY).ceil() + 1;

        final icons = [
          Icons.wallet_outlined,
          Icons.credit_card_outlined,
          Icons.account_balance_outlined,
          Icons.shopping_bag_outlined,
          Icons.receipt_long_outlined,
          Icons.payments_outlined,
          Icons.savings_outlined,
          Icons.coffee_outlined,
          Icons.restaurant_outlined,
          Icons.directions_car_outlined,
          Icons.flight_outlined,
          Icons.store_outlined,
          Icons.trending_up_outlined,
          Icons.home_outlined,
          Icons.electric_bolt_outlined,
          Icons.medical_services_outlined,
          Icons.fitness_center_outlined,
          Icons.train_outlined,
          Icons.phone_iphone_outlined,
          Icons.laptop_outlined,
          Icons.monetization_on_outlined,
          Icons.attach_money_outlined,
          Icons.shopping_cart_outlined,
          Icons.local_gas_station_outlined,
          Icons.local_grocery_store_outlined,
          Icons.local_dining_outlined,
          Icons.local_hospital_outlined,
          Icons.local_movies_outlined,
          Icons.local_offer_outlined,
          Icons.local_pharmacy_outlined,
          Icons.local_pizza_outlined,
          Icons.local_play_outlined,
          Icons.local_post_office_outlined,
          Icons.local_printshop_outlined,
          Icons.local_taxi_outlined,
          Icons.local_atm_outlined,
          Icons.local_bar_outlined,
          Icons.local_cafe_outlined,
          Icons.local_car_wash_outlined,
          Icons.local_convenience_store_outlined,
          Icons.local_florist_outlined,
        ];

        final iconColor = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05);

        final List<Widget> children = [];

        for (int row = -1; row <= rows; row++) {
          for (int col = -1; col <= cols; col++) {
            // Stagger every other row by half the X spacing
            final offsetX = (row % 2 != 0) ? spacingX / 2 : 0.0;
            final x = col * spacingX + offsetX;
            final y = row * spacingY;
            
            final iconIndex = (row * cols + col).abs() % icons.length;
            final icon = icons[iconIndex];
            
            
            // Deterministic rotation and size for an organic, scattered look
            final angle = ((row * 7 + col * 13) % 15) * 0.1 - 0.45; 
            final size = 24.0 + ((row * 11 + col * 17) % 3) * 4.0;

            children.add(
              Positioned(
                left: x,
                top: y,
                child: Transform.rotate(
                  angle: angle,
                  child: Icon(icon, color: iconColor, size: size),
                ),
              ),
            );
          }
        }

        return Stack(
          clipBehavior: Clip.none,
          children: children,
        );
      },
    );
  }
}
