<?php

declare(strict_types=1);

namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Component\Routing\Annotation\Route;
use Twig\Environment;

#[AsController]
final class HomeController
{
    public function __construct(
        private readonly Environment $twig
    ) {
    }

    #[Route('/', name: 'home')]
    public function __invoke(): Response
    {
        return new Response($this->twig->render('home.html.twig'));
    }
}
