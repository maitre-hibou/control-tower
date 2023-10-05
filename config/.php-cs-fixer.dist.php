<?php

$finder = (new PhpCsFixer\Finder())
    ->in(__DIR__.'/../src')
    ->exclude('var')
;

return (new PhpCsFixer\Config())
    ->setRules([
        '@Symfony' => true,
        'strict_param' => true,
        'strict_comparison' => true,
        'array_syntax' => ['syntax' => 'short'],
        'phpdoc_to_comment' => false,
    ])
    ->setFinder($finder)
;
