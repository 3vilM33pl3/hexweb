---
title: "About"
date: 2020-07-28T18:31:03+01:00
draft: true
image: Shop.png
---
"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

When $\(a \ne 0\)$, there are two solutions to $\(ax^2 + bx + c = 0\)$ and they are $$\[x = {-b \pm \sqrt{b^2-4ac} \over 2a}.\]$$


```c++ {linenos=true}
if (!DesiredMovementThisFrame.IsNearlyZero())
{
    FHitResult Hit;
    SafeMoveUpdatedComponent(DesiredMovementThisFrame, 
                             UpdatedComponent->GetComponentRotation(), true, Hit);

    if (Hit.IsValidBlockingHit())
    {
        SlideAlongSurface(DesiredMovementThisFrame, 1.f - Hit.Time, Hit.Normal, Hit);
    }
}
```